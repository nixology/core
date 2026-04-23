{
  inputs,
  ...
}:
let
  module = {
    imports = [
      "${inputs.flake-parts}/modules/withSystem.nix"
    ];
  };

  component = {
    inherit module;
    meta = {
      shortDescription = "flake-parts withSystem component";
    };
  };
in
{
  imports = [ module ];
  flake.components = {
    nixology.core.withSystem = component;
  };
}
