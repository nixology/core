{
  config,
  inputs,
  lib,
  ...
}:
let
  systems = config.partitions.systems.extraInputs.default;

  module = {
    systems = lib.mkDefault (import systems);
  };

  component = {
    inherit module;
    dependencies = with inputs.self.components; [ nixology.core.perSystem ];
    meta = {
      shortDescription = "default systems";
    };
  };

  checks =
    { config, ... }:
    {
      perSystem =
        { pkgs, ... }:
        let
          eval = config.flake.lib.evalComponent { inherit inputs; } (
            with inputs.self.components; nixology.core.systems
          );
        in
        {
          checks.core-systems = pkgs.runCommandLocal "core-systems-check" { } ''
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
    nixology.core.systems = component;
  };
}
