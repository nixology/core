{ config, ... }:
let
  pkgs = config.partitions.pkgs.extraInputs;

  module = {
    perSystem = { system, ... }: {
      _module.args.pkgs = builtins.seq pkgs.nixpkgs-darwin pkgs.nixpkgs-darwin.legacyPackages.${system};
    };
  };

  component = {
    inherit module;
    meta.description = "Provides access to standard packages by using nixpkgs-darwin as the package source, making it available as the pkgs argument across all perSystem configurations";
  };
in
{
  flake.components.nixology.pkgs.nixpkgs-darwin = component;
}
