{ inputs, lib, ... }:
let
  flake = {
    imports = [
      inputs.flake-parts.flakeModules.modules
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
lib.mkComponent {
  name = lib.basename __curPos.file;

  modules = { inherit flake; };

  dependencies = with inputs.self.components; [ nixology.core.schemas ];

  meta = {
    description = "Provide the `modules` flake output for modules usable by any module system.";
    shortDescription = "generic modules";
  };
}
