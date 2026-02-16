{
  description = "A collection of flake components for various purposes.";

  inputs.flake-parts.url = "github:hercules-ci/flake-parts";

  outputs = inputs:
    let flakeref = "github:nixology/std"; in
    with import ./modules/lib.nix { inherit inputs; }; with flake.lib;
    mkFlake { inherit flakeref inputs; } { imports = modulesIn ./modules; };
}
