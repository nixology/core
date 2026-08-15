{
  config,
  inputs,
  lib,
  ...
}:
let
  inherit (config.partitions.schemas.extraInputs) flake-schemas;

  flake = {
    options = {
      flake.schemas = lib.mkOption {
        type = lib.types.lazyAttrsOf (lib.types.lazyAttrsOf lib.types.anything);
        default = { };
        description = "Schemas for flake output types.";
      };
    };

    config = {
      flake.schemas = {
        inherit (flake-schemas.exportedSchemas) schemas;
      };
    };
  };
in
lib.mkComponent {
  name = lib.basename __curPos.file;

  modules = { inherit flake; };

  meta = {
    description = "Flake schemas used by this flake.";
    shortDescription = "flake schemas used by this flake";
  };
}
