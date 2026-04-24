{
  inputs,
  ...
}:
let
  module = {
    imports = [
      "${inputs.flake-parts}/modules/withSystem.nix"
    ];
  };

  component = {
    inherit module;
    meta = {
      shortDescription = "flake-parts withSystem component";
    };
  };

  checks =
    { config, ... }:
    {
      perSystem =
        { pkgs, ... }:
        let
          eval = config.flake.lib.evalComponent { inherit inputs; } (
            with inputs.self.components; nixology.core.withSystem
          );
        in
        {
          checks.core-withSystem = pkgs.runCommandLocal "core-withSystem-check" { } ''
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
    nixology.core.withSystem = component;
  };
}
