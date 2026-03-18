{ config, inputs, lib, ... }:
let
  flake-schemas = config.partitions.schemas.extraInputs.flake-schemas;

  module = { config, ... }: {
    imports = [
      "${inputs.flake-parts}/modules/debug.nix"
    ];

    config = lib.mkIf config.debug {
      flake.schemas = let inherit (flake-schemas.lib) mkChildren; in {
        allSystems = {
          version = 1;
          doc = ''
            The `allSystems` flake output provides the perSystem flake-parts configuration.
            An attribute set of configured systems, each consisting of the `perSystem` attributes, plus the extra attributes `_module`, `config`, `options`, `extendModules`.
            N.B. these are not part of the `config` parameter, but are merged in for debugging convenience.
          '';
          inventory =
            output: mkChildren (
              builtins.mapAttrs
                (name: value: {
                  what = "perSystem flake-parts configuration";
                })
                output
            );
        };

        debug = {
          version = 1;
          doc = ''
            The `debug` flake output provides the top-level flake-parts configuration.
            An attribute set consisting of the `config` attributes, plus the extra attributes `_module`, `config`, `options`, `extendModules`.
            N.B. these are not part of the `config` parameter, but are merged in for debugging convenience.
          '';
          inventory = output: { what = "top-level flake-parts configuration"; };
        };

        currentSystem = {
          version = 1;
          doc = ''
            The `currentSystem` flake output provides the perSystem flake-parts configuration for the current system.
            An attribute set consisting of the `perSystem` attributes, plus the extra attributes `_module`, `config`, `options`, `extendModules`.
            N.B. these are not part of the `config` parameter, but are merged in for debugging convenience.
            Only avaiable in impure mode.
          '';
          inventory = output: { what = "perSystem flake-parts configuration for ${output.allModuleArgs.system}"; };
        };
      };
    };
  };

  component = {
    inherit module;
    dependencies = with inputs.self.components; [
      nixology.std.schemas
    ];
    meta = {
      description = "Expose debug attributes for the flake.";
      shortDescription = "expose debug attributes for the flake";
    };
  };
in
{
  imports = [ module ];
  flake.components = { nixology.std.debug = component; };
}
