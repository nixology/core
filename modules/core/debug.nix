{
  config,
  inputs,
  lib,
  ...
}:
let
  module =
    let
      flake-schemas = config.partitions.schemas.extraInputs.flake-schemas;
      inherit (flake-schemas.lib) mkChildren;
    in
    { config, ... }:
    {
      imports = [
        "${inputs.flake-parts}/modules/debug.nix"
      ];

      config = lib.mkIf config.debug {
        flake.schemas =
          let
            version = 1;
          in
          {
            allSystems = {
              inherit version;
              doc = ''
                The `allSystems` flake output provides the perSystem flake-parts configuration.
                An attribute set of configured systems, each consisting of the `perSystem` attributes, plus the extra attributes `_module`, `config`, `options`, `extendModules`.
                N.B. these are not part of the `config` parameter, but are merged in for debugging convenience.
              '';
              inventory =
                output:
                mkChildren (
                  builtins.mapAttrs (name: value: {
                    what = "perSystem flake-parts configuration";
                  }) output
                );
            };

            debug = {
              inherit version;
              doc = ''
                The `debug` flake output provides the top-level flake-parts configuration.
                An attribute set consisting of the `config` attributes, plus the extra attributes `_module`, `config`, `options`, `extendModules`.
                N.B. these are not part of the `config` parameter, but are merged in for debugging convenience.
              '';
              inventory = output: { what = "top-level flake-parts configuration"; };
            };

            currentSystem = {
              inherit version;
              doc = ''
                The `currentSystem` flake output provides the perSystem flake-parts configuration for the current system.
                An attribute set consisting of the `perSystem` attributes, plus the extra attributes `_module`, `config`, `options`, `extendModules`.
                N.B. these are not part of the `config` parameter, but are merged in for debugging convenience.
                Only available in impure mode.
              '';
              inventory = output: {
                what = "perSystem flake-parts configuration for ${output.allModuleArgs.system}";
              };
            };
          };
      };
    };

  component = {
    inherit module;
    dependencies = with inputs.self.components; [
      nixology.core.flake
      nixology.core.perSystem
      nixology.core.schemas
    ];
    meta = {
      description = "Expose debug attributes for the flake.";
      shortDescription = "expose debug attributes for the flake";
    };
  };

  checks =
    { config, ... }:
    {
      perSystem =
        { pkgs, ... }:
        let
          evalModule = module: config.flake.lib.evalFlakeModule null { inherit inputs; } module;

          eval = evalModule (with inputs.self.components; nixology.core.debug.module);

          evalWithTrue = evalModule {
            imports = [
              { debug = true; }
              (with inputs.self.components; nixology.core.debug.module)
            ];
          };
        in
        {
          checks.core-debug = pkgs.runCommandLocal "core-debug-check" { } ''
            : ${builtins.seq eval.config "ok"}
            : ${builtins.seq evalWithTrue.config "ok"}
            touch $out
          '';
        };
    };
in
{
  imports = [
    checks
    module
  ];
  flake.components = {
    nixology.core.debug = component;
  };
}
