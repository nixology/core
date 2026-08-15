{
  config,
  inputs,
  lib,
  ...
}:
let
  flake = {
    imports = [
      "${inputs.flake-parts}/modules/debug.nix"
    ];

    config = {
      debug = lib.mkDefault true;
      flake.schemas = { inherit (config.flake.exportedSchemas) allSystems currentSystem debug; };
    };
  };
in
lib.mkComponent {
  name = lib.basename __curPos.file;

  modules = { inherit flake; };

  dependencies = with inputs.self.components; [
    nixology.core.flake
  ];

  meta = {
    description = "Expose debug attributes for the flake.";
    shortDescription = "expose debug attributes for the flake";
  };
}
