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
    meta = {
      shortDescription = "flake schemas";
    };
  };
in
{
  imports = [ module ];
  flake.components = {
    nixology.std.schemas = component;
  };
}
