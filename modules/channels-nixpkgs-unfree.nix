{ config, ... }:
let
  channels = config.partitions.pkgs.extraInputs;

  module = {
    perSystem = { system, ... }: {
      _module.args.pkgs = builtins.seq channels.nixpkgs-unfree channels.nixpkgs-unfree.legacyPackages.${system};
    };
  };

  component = {
    inherit module;
    meta.description = "Provides access to unfree/proprietary packages by using nixpkgs-unfree channel as the package source, making it available as the pkgs argument across all perSystem configurations";
  };
in
{
  flake.components.nixology.channels.nixpkgs-unfree = component;
}
