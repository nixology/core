{
  config,
  inputs,
  lib,
  ...
}:
let
  module = { };

  component = {
    inherit module;
    dependencies = with inputs.self.components; [
      nixology.core.flake
      nixology.core.moduleWithSystem
      nixology.core.perSystem
      nixology.core.pkgs
      nixology.core.systems
      nixology.core.transposition
      nixology.core.withSystem
    ];
    meta = {
      shortDescription = "default module for nixology";
    };
  };
in
{
  imports = [ module ];
  flake.components = {
    nixology.core.default = component;
  };
}
