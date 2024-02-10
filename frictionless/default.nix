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
  hatch-vcs,
  hatch-fancy-pypi-readme,
  pyrsistent,
}: let
  marko = buildPythonPackage rec {
    pname = "marko";
    version = "2.0.2";
    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-UC322CcTnqcmXYGfT+NmRYn0d0mX7/dY3Di+pPUjUOY";
    };
    format = "pyproject";
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
    format = "pyproject";
    doCheck = false;
    nativeBuildInputs = [
      setuptools
      setuptools-scm
      wheel
    ];
  };

  jsonschema = buildPythonPackage rec {
    pname = "jsonschema";
    # jsonschema is already packaged in nixpkgs. However, frictionless's pyproject.toml requires jsonschema < v4.17.3. However this version from an old nixpkgs commit is built against a different python version a few PATCH versions behind, which makes it incompatible with the current Python version.
    version = "4.17.3";
    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-D4ZEN6uLYHa6ZwdFPvj5imoNUSqA6T+KvbZ29zfstg0=";
    };
    format = "pyproject";
    doCheck = false;
    nativeBuildInputs = [
      hatchling
      hatch-vcs
      hatch-fancy-pypi-readme
    ];
    propagatedBuildInputs = [
      attrs
      pyrsistent
    ];
  };
in
  buildPythonPackage rec {
    pname = "frictionless";
    version = "5.16.1";
    doCheck = false;
    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-q0v+VfXYMcFaFnYGhQNv3YXJAm0tfGM7ZnKxsE+MSMY";
    };
    format = "pyproject";
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
