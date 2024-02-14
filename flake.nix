{
  description = "Description for the project";

  inputs = {
    nixpkgs-older.url = "github:NixOS/nixpkgs/da5adce0ffaff10f6d0fee72a02a5ed9d01b52fc";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    devshell.url = "github:numtide/devshell";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    poetry2nix.url = "github:nix-community/poetry2nix";
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        inputs.devshell.flakeModule
        inputs.treefmt-nix.flakeModule
      ];
      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin"];
      perSystem = {
        config,
        self',
        inputs',
        pkgs,
        pkgs-older,
        system,
        ...
      }: {
        # This sets `pkgs` to a nixpkgs with allowUnfree option set.
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
        _module.args.pkgs-older = import inputs.nixpkgs-older {
          inherit system;
          config.allowUnfree = true;
        };
        # Per-system attributes can be defined here. The self' and inputs'
        # module parameters provide easy access to attributes of the same
        # system.
        treefmt = {
          projectRootFile = "flake.nix";
          programs = {
            alejandra.enable = true;
            mdformat.enable = true;
            black.enable = true;
          };
        };
        devshells = {
          tfc_utils = import ./tfc_utils/devshell.nix {pkgs = pkgs;};
        };
        # Equivalent to  inputs'.nixpkgs.legacyPackages.hello;
        packages = {
          frictionless =
            pkgs.python311Packages.callPackage ./packages/frictionless/default.nix {
            };
          tfc_utils = pkgs.python311Packages.callPackage ./tfc_utils/default.nix {};
          eg-admin-zones = pkgs.callPackage ./packages/eg-admin-zones {};
        };
      };
      flake = {
        # The usual flake attributes can be defined here, including system-
        # agnostic ones like nixosModule and system-enumerating ones, although
        # those are more easily expressed in perSystem.
      };
    };
}
