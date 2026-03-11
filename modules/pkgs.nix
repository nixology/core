{ config, lib, ... }:
let
  variants = [ "darwin" "nixos" "nixos-small" "nixos-unstable" "nixos-unstable-small" "unfree" "unstable" ];

  pkgs = map
    (variant:
      let
        pkgs = config.partitions."pkgs-${variant}".extraInputs;

        module = {
          perSystem = { system, ... }: {
            _module.args.pkgs = builtins.seq pkgs.nixpkgs pkgs.nixpkgs.legacyPackages.${system};
          };
        };
      in
      {
        inherit variant;
        component = {
          inherit module;
          meta.description = "Provides access to standard packages by using ${variant} pkgs as the package source, making it available as the pkgs argument across all perSystem configurations";
        };
      }
    )
    variants;
in
builtins.foldl' lib.recursiveUpdate { } (map
  (pkgs': {
    flake.components = { nixology.pkgs.${pkgs'.variant} = pkgs'.component; };
  })
  pkgs)
