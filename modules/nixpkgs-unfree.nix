{ config, ... }:
let
  # capture partition inputs from config of outer flake
  # so that is is part of the component
  inputs = config.partitions.default.extraInputs;

  module = {
    perSystem = { lib, system, ... }: {
      _module.args.pkgs = lib.mkDefault (
        builtins.seq inputs.nixpkgs-unfree inputs.nixpkgs-unfree.legacyPackages.${system}
      );
    };
  };

  component = {
    inherit module;
  };
in
{
  flake.components.nixology.std.nixpkgs-unfree = component;
}
