{ ... }@local:
let
  inherit (local.inputs.self.components) nixology;

  implementation =
    { ... }@module:
    let
      inherit (local.lib) mkOption;
      inherit (local.lib.components) evalComponent;
      inherit (local.lib.types) listOf str;
    in
    {
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
          checks =
            let
              inherit (evalComponent { inherit (module) inputs; } nixology.core.moduleClasses)
                config
                ;
            in
            {
              nixology-core-moduleClasses = pkgs.runCommandLocal "checks" {
                check_module_classes = builtins.seq config.moduleClasses "ok";
              } "touch $out";
            };
        };
      };
    };
in
{
  imports = [
    implementation
  ];

  flake.components = {
    nixology.core.moduleClasses = {
      inherit implementation;

      dependencies = [
        nixology.core.perSystem
      ];

      meta = {
        description = "Configure module classes supported by components.";
        shortDescription = "valid module classes";
      };
    };
  };
}
