{
  config,
  inputs,
  lib,
  ...
}:
let
  inherit (lib) mkOption;
  inherit (lib.types) anything lazyAttrsOf;

  inherit (config.partitions.schemas.extraInputs) flake-schemas;

  flake = {
    options = {
      flake.schemas = mkOption {
        type = lazyAttrsOf (lazyAttrsOf anything);
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

  dependencies = with inputs.self.components; [ nixology.core.flake ];

  meta = {
    description = "Flake schemas used by this flake.";
    shortDescription = "flake schemas used by this flake";
  };
}
