{
  lib,
  buildPythonPackage,
  duckdb,
  polars,
  geopandas,
  pandas,
  shapely,
  setuptools,
  setuptools-scm,
  wheel,
}:
buildPythonPackage {
  name = "tfc_utils";
  src = ./.;

  nativeBuildInputs = [
    setuptools
    setuptools-scm
    wheel
  ];

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
    "tfc_utils"
  ];
}
