{
  config,
  inputs,
  lib,
  ...
}:
let
  inherit (lib) mkOption;
  inherit (lib.types) lazyAttrsOf anything;

  inherit (config.partitions.schemas.extraInputs) flake-schemas;

  flake = {
    options = {
      flake.exportedSchemas = mkOption {
        type = lazyAttrsOf (lazyAttrsOf anything);
        default = { };
        description = "Schemas for other flakes to use.";
      };
    };

    config = {
      flake.schemas = {
        inherit (flake-schemas.exportedSchemas) exportedSchemas;
      };
    };
  };
in
lib.mkComponent {
  name = lib.basename __curPos.file;

  modules = { inherit flake; };

  dependencies = with inputs.self.components; [
    nixology.core.schemas
  ];

  meta = {
    description = "Flake schemas exported for other flakes to use.";
    shortDescription = "flake schemas exported for other flakes to use";
  };
}
