{
  lib,
  python310Packages,
}:
python310Packages.buildPythonPackage {
  name = "utils";
  src = ./.;
  buildInputs = with python310Packages; [
    duckdb
    polars
    geopandas
    pandas
    shapely
  ];

  # has no tests
  doCheck = false;

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
