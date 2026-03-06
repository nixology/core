{ config, ... }:
let
  pkgs = config.partitions.nixpkgs-nixos-unstable-small.extraInputs;

  module = {
    perSystem = { system, ... }: {
      _module.args.pkgs = builtins.seq pkgs.nixpkgs pkgs.nixpkgs.legacyPackages.${system};
    };
  };

  component = {
    inherit module;
    meta.description = "Provides access to standard packages by using small unstable nixos nixpkgs as the package source, making it available as the pkgs argument across all perSystem configurations";
  };
in
{
  flake.components.nixology.nixpkgs.nixos-unstable-small = component;
}
