{
  stdenv,
  lib,
  buildPythonPackage,
  fetchPypi,
  pythonOlder,
  pytestCheckHook,
  fastparquet,
  attrs,
  jinja2,
  pyyaml,
  isodate,
  rfc3986,
  chardet,
  pydantic,
  requests,
  humanize,
  tabulate,
  jsonschema,
  simpleeval,
  stringcase,
  typer,
  validators,
  python-slugify,
  python-dateutil,
  typing-extensions,
  # The following are not even defined in the pyproject.toml!
  rich,
  pdm,
  pdm-backend,
  pygments,
  # Python tools
  setuptools,
  setuptools-scm,
  wheel,
  hatchling,
}: let
  marko = buildPythonPackage rec {
    pname = "marko";
    version = "2.0.1";
    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-tZ7MZMIYW/XVmIosKpr8i29y2QR4ltEg1PMuFLtsaW0=";
    };
    pyproject = true;
    nativeBuildInputs = [
      pdm
      pdm-backend
    ];
    propagatedBuildInputs = [
      # Those are actually optional dependencies. How to deal with those when packaging python packages in nix?
      python-slugify
      pygments
    ];
  };

  petl = buildPythonPackage rec {
    pname = "petl";
    version = "1.7.14";
    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-1IAuPEgEv4XyJnoBAvytNcYeajfJDZ4aFnQzHzWpCn8=";
    };
    pyproject = true;
    nativeBuildInputs = [
      setuptools
      setuptools-scm
      wheel
    ];
  };
  hera = buildPythonPackage rec {
    pname = "hera";
    version = "5.13.1";
    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-1IAuPEgEv4XyJnoBAvytNcYeajfJDZ4aFnQzHzWpCn8=";
    };
    pyproject = true;
    nativeBuildInputs = [
      setuptools
      setuptools-scm
      wheel
    ];
  };
in
  buildPythonPackage rec {
    pname = "frictionless";
    version = "5.16.0";
    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-6SIo8lleB6biJyAtgfZu+IsMdgPqnpUZlCCr2//a2QY=";
    };
    pyproject = true;
    nativeBuildInputs = [
      hatchling
    ];
    propagatedBuildInputs = [
      # # Specify dependencies
      petl
      marko
      attrs
      jinja2
      pyyaml
      isodate
      rfc3986
      chardet
      pydantic
      requests
      humanize
      tabulate
      jsonschema
      simpleeval
      stringcase
      typer
      validators
      python-slugify
      python-dateutil
      typing-extensions
      # The following are not even defined in the pyproject.toml!
      rich
    ];

    passthru.optional-dependencies = {
      parquet = [
        fastparquet
      ];
    };

    meta = with lib; {
      description = "The uncompromising Python code formatter";
      homepage = "https://github.com/psf/black";
      changelog = "https://github.com/psf/black/blob/${version}/CHANGES.md";
      license = licenses.mit;
      mainProgram = "frictionless";
      maintainers = with maintainers; [sveitser autophagy];
    };
  }
