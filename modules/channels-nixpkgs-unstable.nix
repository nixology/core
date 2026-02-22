{ config, ... }:
let
  channels = config.partitions.pkgs.extraInputs;

  module = {
    perSystem = { system, ... }: {
      _module.args.pkgs = builtins.seq channels.nixpkgs-unstable channels.nixpkgs-unstable.legacyPackages.${system};
    };
  };

  component = {
    inherit module;
  };
in
{
  flake.components.nixology.channels.nixpkgs-unstable = component;
}
