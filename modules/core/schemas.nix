{ config, inputs, ... }:
let
  flake-schemas = config.partitions.schemas.extraInputs.flake-schemas;

  module =
    { lib, ... }:
    {
      options =
        with lib;
        with types;
        {
          flake.schemas = mkOption {
            type = lazyAttrsOf (lazyAttrsOf anything);
            default = { };
            description = "Schemas for flake output types.";
          };
        };
      config = {
        flake.schemas = { inherit (flake-schemas.schemas) schemas; };
      };
    };

  component = {
    inherit module;
    dependencies = with inputs.self.components; [ nixology.core.flake ];
    meta = {
      shortDescription = "flake schemas";
    };
  };

  checks =
    { config, ... }:
    {
      perSystem =
        { pkgs, ... }:
        let
          eval = config.flake.lib.evalComponent { inherit inputs; } (
            with inputs.self.components; nixology.core.schemas
          );
        in
        {
          checks.core-schemas = pkgs.runCommandLocal "core-schemas-check" { } ''
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
    nixology.core.schemas = component;
  };
}
