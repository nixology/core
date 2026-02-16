{
  description = "A collection of flake components for various purposes.";

  inputs.flake-parts.url = "github:hercules-ci/flake-parts";

  outputs =
    inputs:
    let
      modules =
        with inputs.flake-parts.inputs.nixpkgs-lib.lib;
        (filter (n: hasSuffix ".nix" n) (filesystem.listFilesRecursive ./modules))
        ++ [ { flake.meta.flakeref = "github:nixology/std"; } ];
    in
    with inputs.flake-parts.lib;
    mkFlake { inherit inputs; } {
      debug = true;
      imports = modules;
    };
}
