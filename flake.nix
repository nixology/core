{
  description = "A collection of flake components for various purposes.";

  inputs.flake-parts.url = "github:hercules-ci/flake-parts";

  outputs = inputs:
    with import ./modules/std/lib.nix { inherit inputs; }; with flake.lib;
    mkFlake { inherit inputs; } { imports = modulesIn ./modules; };
}
