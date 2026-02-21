{ config, ... }:
let
  pkgs = config.partitions.pkgs.extraInputs;

  module = {
    perSystem = { system, ... }: {
      _module.args.pkgs = builtins.seq pkgs.nixpkgs-unstable pkgs.nixpkgs-unstable.legacyPackages.${system};
    };
  };

  component = {
    inherit module;
  };
in
{
  flake.components.nixology.std.nixpkgs-unstable = component;
}
