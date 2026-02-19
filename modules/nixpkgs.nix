{ config, ... }:
let
  # capture partition inputs from config of outer flake
  # so that is is part of the component
  inputs = config.partitions.pkgs.extraInputs;

  module = {
    perSystem = { lib, system, ... }: {
      _module.args.pkgs = lib.mkForce (builtins.seq inputs.nixpkgs inputs.nixpkgs.legacyPackages.${system});
    };
  };

  component = {
    inherit module;
    meta.description = "Provides access to standard packages by using nixpkgs as the package source, making it available as the pkgs argument across all perSystem configurations";
  };
in
{
  flake.components.nixology.std.nixpkgs = component;
}
