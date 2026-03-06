{ inputs, ... }:
let
  variants = [ "darwin" "nixos" "nixos-small" "nixos-unstable" "nixos-unstable-small" "unfree" "unstable" ];

  channels = let partition = "channels"; in map
    (variant:
      {
        partitions."${partition}-${variant}".extraInputsFlake = ../partitions/${partition}/${variant};
      }
    )
    variants;

  pkgs = let partition = "pkgs"; in map
    (variant:
      {
        partitions."${partition}-${variant}".extraInputsFlake = ../partitions/${partition}/${variant};
      }
    )
    variants;

  systems = let partition = "systems"; in
    {
      partitions.${partition}.extraInputsFlake = ../partitions/${partition};
    };

  module = {
    imports = [
      inputs.flake-parts.flakeModules.partitions
      systems
    ] ++ channels ++ pkgs;
  };
in
module
