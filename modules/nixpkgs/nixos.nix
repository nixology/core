{ config, ... }:
let
  pkgs = config.partitions.nixpkgs-nixos.extraInputs;

  module = {
    perSystem = { system, ... }: {
      _module.args.pkgs = builtins.seq pkgs.nixpkgs pkgs.nixpkgs.legacyPackages.${system};
    };
  };

  component = {
    inherit module;
    meta.description = "Provides access to standard packages by using nixos nixpkgs as the package source, making it available as the pkgs argument across all perSystem configurations";
  };
in
{
  flake.components.nixology.nixpkgs.nixos = component;
}
