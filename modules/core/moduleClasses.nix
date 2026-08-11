{ lib, inputs, ... }:
let
  flake =
    {
      config,
      inputs,
      lib,
      ...
    }:
    {
      options =
        with lib;
        with types;
        {
          moduleClasses = mkOption {
            type = listOf str;
            default = [
              "flake"
              "homeManager"
              "nixos"
              "darwin"
            ];
            description = "Module classes supported by components.";
          };
        };

      config = {
        perSystem = { pkgs, ... }: {
          checks = {
            nixology-core-moduleClasses =
              let
                unsupportedModuleClasses = builtins.filter (name: !(builtins.elem name config.moduleClasses)) (
                  builtins.attrNames (config.flake.modules or { })
                );
              in
              assert lib.assertMsg (unsupportedModuleClasses == [ ])
                "flake.modules contains unsupported module classes: ${builtins.concatStringsSep ", " unsupportedModuleClasses}";
              pkgs.runCommandLocal "checks" { } "touch $out";
          };
        };
      };
    };
in
lib.mkComponent __curPos.file {
  modules = { inherit flake; };

  dependencies = with inputs.self.components; [
    nixology.core.perSystem
  ];

  meta = {
    description = "Configure module classes supported by components.";
    shortDescription = "valid module classes";
  };
}
