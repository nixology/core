{
  config,
  inputs,
  lib,
  ...
}:
let
  inherit (lib)
    isAttrs
    mapAttrs
    ;

  inherit (config.partitions.schemas.extraInputs) flake-schemas;
  inherit (flake-schemas.lib) mkChildren;

  flake = {
    config = {
      flake.exportedSchemas = {
        components = {
          version = 1;

          doc = "The `components` flake output provides importable components.";

          inventory =
            let
              recurse =
                components:
                mkChildren (
                  mapAttrs (
                    _name: value:
                    if isAttrs value && value ? module then
                      {
                        what =
                          if value.meta.shortDescription != null then
                            "component (${value.meta.shortDescription})"
                          else
                            "component attribute";
                      }
                    else
                      recurse value
                  ) components
                );
            in
            recurse;
        };
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
    description = "Exported schemas for nixology component attributes.";
    shortDescription = "exported schemas for nixology component attributes";
  };
}
