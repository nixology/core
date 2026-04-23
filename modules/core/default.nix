{
  config,
  inputs,
  lib,
  ...
}:
let
  nixpkgs = config.partitions.channels-unstable.extraInputs.nixpkgs;
  systems = config.partitions.systems.extraInputs.default;

  module = {
    imports = [
      "${inputs.flake-parts}/modules/flake.nix"
      "${inputs.flake-parts}/modules/moduleWithSystem.nix"
      "${inputs.flake-parts}/modules/nixpkgs.nix"
      "${inputs.flake-parts}/modules/perSystem.nix"
      "${inputs.flake-parts}/modules/transposition.nix"
      "${inputs.flake-parts}/modules/withSystem.nix"
    ];

    # default pkgs
    perSystem =
      { system, ... }:
      {
        _module.args.pkgs = lib.mkDefault (builtins.seq nixpkgs nixpkgs.legacyPackages.${system});
      };

    # default systems
    systems = lib.mkDefault (import systems);

    # default transposed attributes
    transposition = lib.mkOptionDefault { };
  };

  component = {
    inherit module;
    meta = {
      shortDescription = "default module for nixology";
    };
  };
in
{
  imports = [ module ];
  flake.components = {
    nixology.core.default = component;
  };
}
