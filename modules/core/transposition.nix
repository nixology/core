{
  inputs,
  lib,
  ...
}:
let
  module = {
    imports = [
      "${inputs.flake-parts}/modules/transposition.nix"
    ];

    # default transposed attributes
    transposition = lib.mkOptionDefault { };
  };

  component = {
    inherit module;
    dependencies = with inputs.self.components; [
      nixology.core.flake
      nixology.core.perSystem
    ];
    meta = {
      shortDescription = "flake-parts transposition component";
    };
  };

  checks =
    { config, ... }:
    {
      perSystem =
        { pkgs, ... }:
        let
          eval = config.flake.lib.evalComponent { inherit inputs; } (
            with inputs.self.components; nixology.core.transposition
          );
        in
        {
          checks.core-transposition = pkgs.runCommandLocal "core-transposition-check" { } ''
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
    nixology.core.transposition = component;
  };
}
