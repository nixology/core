{ lib, inputs, ... }:
let
  inherit (lib) mkOption;
  inherit (lib.types) listOf str;

  flake = args: {
    options = {
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
              configuredModuleClasses = builtins.attrNames (args.config.flake.modules or { });
              unsupportedModuleClasses = builtins.filter (
                name: !(builtins.elem name args.config.moduleClasses)
              ) configuredModuleClasses;
              unsupportedNames = builtins.concatStringsSep ", " unsupportedModuleClasses;
            in
            assert lib.assertMsg (
              unsupportedModuleClasses == [ ]
            ) "flake.modules contains unsupported module classes: ${unsupportedNames}";
            pkgs.runCommandLocal "checks" { } "touch $out";
        };
      };
    };
  };
in
lib.mkComponent {
  name = lib.basename __curPos.file;

  modules = { inherit flake; };

  dependencies = with inputs.self.components; [ nixology.core.perSystem ];

  meta = {
    description = "Configure module classes supported by components.";
    shortDescription = "valid module classes";
  };
}
