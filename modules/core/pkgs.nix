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
    dependencies = with inputs.self.components; [ nixology.core.perSystem ];
    meta = {
      shortDescription = "default pkgs";
    };
  };

  checks =
    { config, ... }:
    {
      perSystem =
        { pkgs, ... }:
        let
          eval = config.flake.lib.evalComponent { inherit inputs; } (
            with inputs.self.components; nixology.core.pkgs
          );
        in
        {
          checks.core-pkgs = pkgs.runCommandLocal "core-pkgs-check" { } ''
            : ${builtins.seq eval.config "ok"}
            touch $out
          '';
        };
    };
in
{
  imports = [
    checks
    module
  ];
  flake.components = {
    nixology.core.pkgs = component;
  };
}
