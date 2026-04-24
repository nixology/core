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
          eval = config.flake.lib.evalFlakeModule null { inherit inputs; } (
            with inputs.self.components; nixology.core.systems.module
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
