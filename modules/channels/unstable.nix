{ config, ... }:
let
  pkgs = config.partitions.channels-unstable.extraInputs;

  module = {
    perSystem = { system, ... }: {
      _module.args.pkgs = builtins.seq pkgs.nixpkgs pkgs.nixpkgs.legacyPackages.${system};
    };
  };

  component = {
    inherit module;
  };
in
{
  flake.components.nixology.channels.unstable = component;
}
