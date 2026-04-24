{
  inputs,
  ...
}:
let
  module = {
    imports = [
      "${inputs.flake-parts}/modules/moduleWithSystem.nix"
    ];
  };

  component = {
    inherit module;
    meta = {
      shortDescription = "flake-parts moduleWithSystem component";
    };
  };

  checks =
    { config, ... }:
    {
      perSystem =
        { pkgs, ... }:
        let
          eval = config.flake.lib.evalFlakeModule null { inherit inputs; } (
            with inputs.self.components; nixology.core.moduleWithSystem.module
          );
        in
        {
          checks.core-moduleWithSystem = pkgs.runCommandLocal "core-moduleWithSystem-check" { } ''
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
    nixology.core.moduleWithSystem = component;
  };
}
