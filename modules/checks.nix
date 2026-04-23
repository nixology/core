{ config, inputs, ... }:
let
  flake-schemas = config.partitions.schemas.extraInputs.flake-schemas;

  checks =
    let
      name = "checks";

      module = {
        imports = [ "${inputs.flake-parts}/modules/${name}.nix" ];
        config = {
          flake.schemas.${name} = flake-schemas.schemas.${name};
        };
      };

      component = {
        inherit module;
        dependencies = with inputs.self.components; [
          nixology.core.schemas
        ];
        meta = {
          shortDescription = "derivations for testing evaluation of this flake";
        };
      };
    in
    component;
in
{
  imports = map (component: component.module) [
    checks
  ];
}
