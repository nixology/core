{ config, inputs, ... }:
let
  module =
    { lib, ... }:
    {
      options =
        with lib;
        with types;
        let
          flakeref = mkOption {
            type = nullOr str;
            description = "The flake reference for this flake.";
            default = null;
          };
        in
        {
          inherit flakeref;
        };
    };

  component = {
    inherit module;
    meta = {
      description = "Provides a unique identifier for the flake.";
    };
  };

  checks =
    { config, ... }:
    {
      perSystem =
        { pkgs, ... }:
        let
          eval = config.flake.lib.evalFlakeModule null { inherit inputs; } (
            with inputs.self.components; nixology.core.flakeref.module
          );
        in
        {
          checks.core-flakeref = pkgs.runCommandLocal "core-flakeref-check" { } ''
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
    nixology.core.flakeref = component;
  };
}
