{
  description = "A collection of flake components for various purposes.";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs: with inputs; let
    modules = with flake-parts.inputs.nixpkgs-lib.lib;
      (filter (n: strings.hasSuffix ".nix" n) (filesystem.listFilesRecursive ./modules))
      ++ [ { flake.meta.flakeref = "github:nixology/nixology"; } ];
    in
    flake-parts.lib.mkFlake { inherit inputs; } { debug = true; imports = modules; };
}
