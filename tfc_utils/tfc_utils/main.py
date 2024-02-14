#!/usr/bin/env python3
import duckdb
from shapely import wkt
import polars as pl
import sqlite3
import math
import geopandas as gpd

def join_one_to_many_then_sample_efficient_v2(
    df1,
    df2,
    left_on,
    right_on,
    df1_sample_size_per_row_col_name=None,
    random_seed=None,
    with_replacement=True,
):
    # TODO: Input checks
    # e.g. left_on length is the same as right_on length
    # e.g. Maybe give a warning if the number of groups for the join columns in both dataframes are not the same. It's important to know because the resultant df will be smaller than the input DF.

    # TODO: Check for duplicate column names between df1 and df2 and raise error requiring the user of the function to remove the duplicates with df2.drop(df1.columns)
    

    COUNT_COL_NAME = "count"

    # Pre-calculate count per group for df1
    df1_group_counts = df1.groupby(left_on).agg(
        (
            pl.col(df1_sample_size_per_row_col_name).sum().alias(COUNT_COL_NAME)
            if df1_sample_size_per_row_col_name is not None
            else pl.count().alias(COUNT_COL_NAME)
        )
    )

    def sample_func(group):
        # Get the values of join columns in current group
        group_name = tuple(
            [group.select(pl.col(col_name).first()).item() for col_name in right_on]
        )

        # Get the sample size from pre-calculated group counts
        df1_group_count = df1_group_counts.filter(
            pl.all_horizontal(
                [
                    pl.col(col_name).eq(group_name[idx])
                    for idx, col_name in enumerate(left_on)
                ]
            )
        ).select(pl.col(COUNT_COL_NAME).sum())

        sample_size = df1_group_count.item() if len(df1_group_count) > 0 else 0
        # TODO: Saner coding style for this part
        final_with_replacement = with_replacement
        if (with_replacement is False) and sample_size > len(group):
            print(
                Warning(
                    f"Problem while sampling without replacement. Pool size ({len(group)}) smaller than requested sample size ({sample_size}) for group {group_name}. Sampling with replacement in this group."
                )
            )

            final_with_replacement = True

        df1_corresponding_group = df1.filter(
            pl.all_horizontal(
                [
                    pl.col(col_name).eq(group_name[idx])
                    for idx, col_name in enumerate(left_on)
                ]
            )
        )

        df1_corresponding_group_exploded = df1_corresponding_group.select(
            pl.all().repeat_by(df1_sample_size_per_row_col_name).explode()
            if df1_sample_size_per_row_col_name
            else pl.all()
        )

        df2_group_random_sample = group.sample(
            n=sample_size, with_replacement=final_with_replacement, seed=random_seed
        ).drop(right_on)

        merged = pl.concat(
            [
                df1_corresponding_group_exploded,
                df2_group_random_sample,
            ],
            how="horizontal",
        )
        return merged

    # Print aggregate stats on how many groups were merged with or without replacement
    return df2.groupby(right_on, maintain_order=False).apply(sample_func)


def read_gpkg_into_gdf_using_duckdb(path, layer_name, geometry_col_name, crs):
    def wkt_loads(x):
        try:
            return wkt.loads(x)
        except Exception as e:
            raise e

    # Initialize DuckDB
    duckdb.sql("install spatial; load spatial;")

    return gpd.GeoDataFrame(
        duckdb.sql(
            # TODO: There seems to be a bug in duckdb's conversion to WKT that messes up multipolygons. The resulting WKT was not parseable by shapely. The WKT had exactly the following erroneous character order between two polygons within the multipolygon --> )(, <--
            f"select *, st_astext({geometry_col_name}) as geom_wkt from st_read('{path}', layer='{layer_name}')"
        )
        .df()
        .assign(**{geometry_col_name: lambda df: df["geom_wkt"].apply(wkt_loads)}),
        crs=crs,
        geometry=geometry_col_name,
    )


def clean_gpkg(path):
    """
    Make GPKG files time and OS independent.

    In GeoPackage metadata:
    - replace last_change date with a placeholder, and
    - round coordinates.

    This allow for comparison of output digests between runs and between OS.
    """
    conn = sqlite3.connect(path)
    cur = conn.cursor()
    for table_name, min_x, min_y, max_x, max_y in cur.execute(
        "SELECT table_name, min_x, min_y, max_x, max_y FROM gpkg_contents"
    ):
        cur.execute(
            "UPDATE gpkg_contents "
            + "SET last_change='2000-01-01T00:00:00Z', min_x=?, min_y=?, max_x=?, max_y=? "
            + "WHERE table_name=?",
            (
                math.floor(min_x),
                math.floor(min_y),
                math.ceil(max_x),
                math.ceil(max_y),
                table_name,
            ),
        )
    conn.commit()
    conn.close()
