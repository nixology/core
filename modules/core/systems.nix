{
  config,
  inputs,
  lib,
  ...
}:
let
  inherit (inputs.self.components) nixology;

  extraInputs = config.partitions.systems.extraInputs;

  variants = [
    "default"
    "default-darwin"
    "default-linux"
    "aarch64-darwin"
    "aarch64-linux"
    "x86_64-linux"
  ];

  mkSystemsComponent =
    variant:
    let
      module = {
        systems =
          let
            filteredSystems = lib.remove "x86_64-darwin" (import extraInputs.${variant});
          in
          if variant == "default" then lib.mkOptionDefault filteredSystems else filteredSystems;
      };
    in
    {
      inherit module;

      dependencies = [ nixology.core.perSystem ];

      meta = {
        description = "Configure the flake systems list using the `${variant}` systems input.";
        shortDescription = "flake systems: ${variant}";
      };
    };

  components = builtins.listToAttrs (
    map (variant: {
      name = variant;
      value = mkSystemsComponent variant;
    }) variants
  );
in
{
  imports = [
    components.default.module
  ];

  flake.components = {
    nixology.systems = components;
  };
}
