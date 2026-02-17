{ config, ... }:
let
  # capture partition inputs from config of outer flake
  # so that is is part of the component
  inputs = config.partitions.pkgs.extraInputs;

  module = {
    perSystem = { lib, system, ... }: {
      _module.args.pkgs = builtins.seq inputs.nixpkgs-unfree inputs.nixpkgs-unfree.legacyPackages.${system};
    };
  };

  component = {
    inherit module;
    meta.description = "Provides access to unfree/proprietary packages by using nixpkgs-unfree as the package source, making it available as the pkgs argument across all perSystem configurations";
  };
in
{
  flake.components.nixology.std.nixpkgs-unfree = component;
}
