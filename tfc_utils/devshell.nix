{pkgs, ...}: {
  devshell = {
    packages =
      [pkgs.python310]
      ++ (with pkgs.python310Packages; [
        duckdb
        polars
        geopandas
        pandas
        shapely
      ]);
  };
}
