{ inputs, ... }:
let
  module = with inputs.flake-parts.flakeModules; partitions;

  component = {
    inherit module;
    dependencies = with inputs.self.components; [ nixology.core.flake ];
    meta = {
      shortDescription = "module for partition management";
    };
  };

  checks =
    { config, ... }:
    {
      perSystem =
        { pkgs, ... }:
        let
          eval = config.flake.lib.evalComponent { inherit inputs; } (
            with inputs.self.components; nixology.core.partitions
          );
        in
        {
          checks.core-partitions = pkgs.runCommandLocal "core-partitions-check" { } ''
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
    nixology.core.partitions = component;
  };
}
