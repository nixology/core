{
  inputs,
  ...
}:
let
  module = {
    imports = [
      "${inputs.flake-parts}/modules/perSystem.nix"
    ];
  };

  component = {
    inherit module;
    dependencies = with inputs.self.components; [
      nixology.core.systems
    ];
    meta = {
      shortDescription = "flake-parts perSystem component";
    };
  };
in
{
  imports = [ module ];
  flake.components = {
    nixology.core.perSystem = component;
  };
}
