{
  config,
  inputs,
  lib,
  ...
}:
let
  nixpkgs = config.partitions.channels-unstable.extraInputs.nixpkgs;

  module = {
    # default pkgs
    perSystem =
      { system, ... }:
      {
        _module.args.pkgs = lib.mkDefault (builtins.seq nixpkgs nixpkgs.legacyPackages.${system});
      };
  };

  component = {
    inherit module;
    meta = {
      shortDescription = "default pkgs";
    };
  };
in
{
  imports = [ module ];
  flake.components = {
    nixology.core.pkgs = component;
  };
}
