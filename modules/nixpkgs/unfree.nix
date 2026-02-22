{ config, ... }:
let
  pkgs = config.partitions.nixpkgs-unfree.extraInputs;

  module = {
    perSystem = { system, ... }: {
      _module.args.pkgs = builtins.seq pkgs.nixpkgs pkgs.nixpkgs.legacyPackages.${system};
    };
  };

  component = {
    inherit module;
    meta.description = "Provides access to unfree/proprietary packages by using unfree nixpkgs as the package source, making it available as the pkgs argument across all perSystem configurations";
  };
in
{
  flake.components.nixology.nixpkgs.unfree = component;
}
