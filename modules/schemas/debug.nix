{
  config,
  inputs,
  lib,
  ...
}:
let
  inherit (config.partitions.schemas.extraInputs) flake-schemas;
  inherit (flake-schemas.lib) mkChildren;

  flake =
    let
      version = 1;

      mkSchema = doc: inventory: {
        inherit version doc inventory;
      };

      perSystemDoc = target: ''
        The `${target}` flake output provides the perSystem flake-parts configuration.

        An attribute set consisting of the `perSystem` attributes, plus the extra
        attributes `_module`, `config`, `options`, `extendModules`.

        N.B. these are not part of the `config` parameter, but are merged in for
        debugging convenience.
      '';
    in
    {
      config = {
        flake.exportedSchemas = {
          allSystems =
            mkSchema
              ''
                The `allSystems` flake output provides the perSystem flake-parts configuration.

                An attribute set of configured systems, each consisting of the `perSystem`
                attributes, plus the extra attributes `_module`, `config`, `options`,
                `extendModules`.

                N.B. these are not part of the `config` parameter, but are merged in for
                debugging convenience.
              ''
              (
                configs:
                mkChildren (
                  builtins.mapAttrs (_system: _config: {
                    what = "flake-parts perSystem config";
                  }) configs
                )
              );

          currentSystem =
            mkSchema
              ''
                ${perSystemDoc "currentSystem"}

                Only available in impure mode.
              ''
              (config: {
                what = "flake-parts perSystem config for ${config.allModuleArgs.system}";
              });

          debug =
            mkSchema
              ''
                The `debug` flake output provides the top-level flake-parts configuration.

                An attribute set consisting of the `config` attributes, plus the extra
                attributes `_module`, `config`, `options`, `extendModules`.

                N.B. these are not part of the `config` parameter, but are merged in for
                debugging convenience.
              ''
              (_config: {
                what = "flake-parts top-level configuration";
              });
        };
      };
    };
in
lib.mkComponent {
  name = lib.basename __curPos.file;
  subdomain = "schemas";

  modules = { inherit flake; };

  dependencies = with inputs.self.components; [ nixology.core.exportedSchemas ];

  meta = {
    description = "Exported schemas for flake-parts debug attributes";
    shortDescription = "exported schemas for flake-parts debug attributes";
  };
}
