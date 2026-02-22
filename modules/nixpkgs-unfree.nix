{ config, ... }:
let
  pkgs = config.partitions.pkgs.extraInputs;

  module = {
    perSystem = { system, ... }: {
      _module.args.pkgs = builtins.seq pkgs.nixpkgs-unfree pkgs.nixpkgs-unfree.legacyPackages.${system};
    };
  };

  component = {
    inherit module;
    meta.description = "Provides access to unfree/proprietary packages by using nixpkgs-unfree as the package source, making it available as the pkgs argument across all perSystem configurations";
  };
in
{
  flake.components.nixology.pkgs.nixpkgs-unfree = component;
}
