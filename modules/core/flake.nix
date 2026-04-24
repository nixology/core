{
  inputs,
  ...
}:
let
  module = {
    imports = [
      "${inputs.flake-parts}/modules/flake.nix"
    ];
  };

  component = {
    inherit module;
    meta = {
      shortDescription = "flake-parts flake component";
    };
  };
in
{
  imports = [ module ];
  flake.components = {
    nixology.core.flake = component;
  };
}
