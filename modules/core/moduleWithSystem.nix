{
  inputs,
  ...
}:
let
  module = {
    imports = [
      "${inputs.flake-parts}/modules/moduleWithSystem.nix"
    ];
  };

  component = {
    inherit module;
    meta = {
      shortDescription = "flake-parts moduleWithSystem component";
    };
  };
in
{
  imports = [ module ];
  flake.components = {
    nixology.core.moduleWithSystem = component;
  };
}
