{ inputs, ... }:
let
  pkgs = [ "darwin" "nixos" "unfree" "unstable" ];

  channels = let partition = "channels"; in map (pkgs:
    {
      partitions."${partition}-${pkgs}".extraInputsFlake = ../partitions/${partition}/${pkgs};
    }
  ) pkgs;

  nixpkgs = let partition = "nixpkgs"; in map (pkgs:
    {
      partitions."${partition}-${pkgs}".extraInputsFlake = ../partitions/${partition}/${pkgs};
    }
  ) pkgs;

  systems = let partition = "systems"; in
    {
      partitions.${partition}.extraInputsFlake = ../partitions/${partition};
    };

  module = {
    imports = [
      inputs.flake-parts.flakeModules.partitions
      systems
    ] ++ channels ++ nixpkgs;
  };
in
module
