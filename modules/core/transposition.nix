{
  inputs,
  lib,
  ...
}:
let
  module = {
    imports = [
      "${inputs.flake-parts}/modules/transposition.nix"
    ];

    # default transposed attributes
    transposition = lib.mkOptionDefault { };
  };

  component = {
    inherit module;
    meta = {
      shortDescription = "flake-parts transposition component";
    };
  };
in
{
  imports = [ module ];
  flake.components = {
    nixology.core.transposition = component;
  };
}
