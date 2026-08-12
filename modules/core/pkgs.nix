{ inputs, lib, ... }:
let
  inherit (lib)
    mkOption
    mkOptionDefault
    throwIf
    ;

  inherit (lib.components) evalComponent;

  inherit (lib.types)
    anything
    bool
    lazyAttrsOf
    listOf
    nullOr
    path
    str
    submodule
    ;

  flake = args: {
    options = {
      pkgs = mkOption {
        description = "The package set configuration for the `pkgs` module argument.";
        default = { };

        type = submodule {
          options = {
            nixpkgs = mkOption {
              type = nullOr path;
              default = if inputs ? nixpkgs then inputs.nixpkgs else null;
              description = "The nixpkgs source to import.";
              apply =
                value:
                (throwIf (value == null) ''
                  nixology: `pkgs.nixpkgs` is not set.

                  Either set `pkgs.nixpkgs` explicitly, or ensure your flake has
                  a `nixpkgs` input (e.g. `inputs.nixpkgs.url = "github:nixos/nixpkgs";`).
                '')
                  value;
            };

            settings = mkOption {
              type = submodule {
                freeformType = lazyAttrsOf anything;

                options = {
                  allowAliases = mkOption {
                    type = bool;
                    default = true;
                  };

                  allowBroken = mkOption {
                    type = bool;
                    default = false;
                  };

                  allowUnfree = mkOption {
                    type = bool;
                    default = false;
                  };

                  allowUnfreePackages = mkOption {
                    type = listOf str;
                    default = [ ];
                  };
                };
              };

              default = { };
              description = "nixpkgs config passed to the nixpkgs import.";
            };
          };
        };
      };
    };

    config = {
      perSystem =
        { pkgs, system, ... }:
        {
          _module.args.pkgs = mkOptionDefault (
            import args.config.pkgs.nixpkgs {
              inherit system;
              config = args.config.pkgs.settings;
            }
          );
        };
    };
  };
in
lib.mkComponent {
  name = lib.basename __curPos.file;

  modules = { inherit flake; };

  dependencies = with inputs.self.components; [ nixology.core.perSystem ];

  meta = {
    description = "Configurable per-system `pkgs` module argument.";
    shortDescription = "configurable per-system pkgs";
  };
}
