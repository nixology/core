{ config, ... }:
let
  channels = config.partitions.pkgs.extraInputs;

  module = {
    perSystem = { system, ... }: {
      _module.args.pkgs = builtins.seq channels.nixpkgs-darwin channels.nixpkgs-darwin.legacyPackages.${system};
    };
  };

  component = {
    inherit module;
    meta.description = "Provides access to standard packages by using nixpkgs-darwin channel as the package source, making it available as the pkgs argument across all perSystem configurations";
  };
in
{
  flake.components.nixology.channels.nixpkgs-darwin = component;
}
