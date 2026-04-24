{
  inputs,
  ...
}:
let
  module = {
    imports = [
      "${inputs.flake-parts}/modules/perSystem.nix"
    ];
  };

  component = {
    inherit module;
    meta = {
      shortDescription = "flake-parts perSystem component";
    };
  };

  checks =
    { config, ... }:
    {
      perSystem =
        { pkgs, ... }:
        let
          eval = config.flake.lib.evalComponent { inherit inputs; } (
            with inputs.self.components; nixology.core.perSystem
          );
        in
        {
          checks.core-perSystem = pkgs.runCommandLocal "core-perSystem-check" { } ''
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
    nixology.core.perSystem = component;
  };
}
