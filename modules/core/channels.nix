{
  config,
  inputs,
  lib,
  ...
}:
let
  variants = [
    "nixos"
    "nixos-small"
    "nixos-unstable"
    "nixos-unstable-small"
    "nixpkgs-darwin"
    "nixpkgs-unstable"
  ];

  mkChannelComponent = variant: {
    module = {
      perSystem =
        { system, ... }:
        let
          nixpkgs = config.partitions.channels.extraInputs.${variant}.inputs.channel;
        in
        {
          _module.args.pkgs = nixpkgs.legacyPackages.${system};
        };
    };

    dependencies = with inputs.self.components; [ nixology.core.perSystem ];

    meta = {
      shortDescription = "package set from ${variant} channel flake";
      description = ''
        Provides access to packages from nixpkgs using the ${variant}
        channel flake as the package source, making it available as the
        pkgs argument across all perSystem configurations.
      '';
    };
  };
in
{
  flake.components = {
    nixology.channels = lib.genAttrs variants mkChannelComponent;
  };
}
