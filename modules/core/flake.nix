{
  inputs,
  ...
}:
let
  module = {
    imports = [
      "${inputs.flake-parts}/modules/flake.nix"
    ];
  };

  component = {
    inherit module;
    meta = {
      shortDescription = "flake-parts flake component";
    };
  };

  checks =
    { config, ... }:
    {
      perSystem =
        { pkgs, ... }:
        let
          eval = config.flake.lib.evalComponent { inherit inputs; } (
            with inputs.self.components; nixology.core.flake
          );
        in
        {
          checks.core-flake = pkgs.runCommandLocal "core-flake-check" { } ''
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
    nixology.core.flake = component;
  };
}
