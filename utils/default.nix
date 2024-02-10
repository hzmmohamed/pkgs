{
  lib,
  buildPythonPackage,
  duckdb,
  polars,
  geopandas,
  pandas,
  shapely,
}:
buildPythonPackage {
  name = "utils";
  src = ./.;
  buildInputs = [
    duckdb
    polars
    geopandas
    pandas
    shapely
  ];

  # has no tests
  doCheck = true;

  pythonImportsCheck = [
    "utils"
  ];
  # propagatedBuildInputs = [
  #   attrs
  #   py
  #   setuptools
  #   six
  #   pluggy
  # ];
}
