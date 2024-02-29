{
  lib,
  python3,
  fetchFromGitHub,
}:
python3.pkgs.buildPythonPackage rec {
  pname = "hera";
  version = "5.13.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "argoproj-labs";
    repo = "hera";
    rev = version;
    hash = "sha256-jx6EKhgHaHMk9iaMm8lbkbxj+omv98ShpFXa/6gpID0=";
  };

  nativeBuildInputs = [
    python3.pkgs.poetry-core
  ];

  propagatedBuildInputs = with python3.pkgs; [
    pydantic
    requests
  ];

  passthru.optional-dependencies = with python3.pkgs; {
    cli = [
      PyYAML
      cappa
    ];
    yaml = [
      PyYAML
    ];
  };

  pythonImportsCheck = ["hera" "hera.workflows"];

  meta = with lib; {
    description = "Hera is an Argo Python SDK. Hera aims to make construction and submission of various Argo Project resources easy and accessible to everyone! Hera abstracts away low-level setup details while still maintaining a consistent vocabulary with Argo. ⭐\u{fe0f} Star the repo if you like it";
    homepage = "https://github.com/argoproj-labs/hera/tree/main";
    changelog = "https://github.com/argoproj-labs/hera/blob/${src.rev}/CHANGELOG.md";
    license = licenses.mit;
    maintainers = with maintainers; [];
    mainProgram = "hera";
  };
}
