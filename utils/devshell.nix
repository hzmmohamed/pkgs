{python310Packages}: {
  devshell = {
    packages = with python310Packages; [
      duckdb
      polars
      geopandas
      pandas
      shapely
    ];
  };
}
