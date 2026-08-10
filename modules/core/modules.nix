{ ... }@local:
let
  inherit (local.inputs.self.components) nixology;

  inherit (local.inputs) flake-parts;

  implementation = {
    imports = [
      flake-parts.flakeModules.modules
    ];

    config = {
      flake.schemas = {

        modules = {
          version = 1;
          doc = ''
            The `modules` flake output contains modules for any module system.
          '';
          inventory = _output: {
            what = "modules for use by other module systems";
          };
        };

      };
    };
  };
in
{
  flake.components = {
    nixology.core.modules = {
      inherit implementation;

      dependencies = [
        nixology.core.schemas
      ];

      meta = {
        description = "Provide the `modules` flake output for modules usable by any module system.";
        shortDescription = "generic modules";
      };
    };
  };
}
