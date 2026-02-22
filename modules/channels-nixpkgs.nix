{ config, ... }:
let
  channels = config.partitions.channels.extraInputs;

  module = {
    perSystem = { system, ... }: {
      _module.args.pkgs = builtins.seq channels.nixpkgs channels.nixpkgs.legacyPackages.${system};
    };
  };

  component = {
    inherit module;
    meta.description = "Provides access to standard packages by using nixpkgs channel as the package source, making it available as the pkgs argument across all perSystem configurations";
  };
in
{
  flake.components.nixology.channels.nixpkgs = component;
}
