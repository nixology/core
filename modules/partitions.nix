{ inputs, ... }:
let
  pkgs = let partition = "pkgs"; in
    {
      partitions.${partition}.extraInputsFlake = ../partitions/${partition};
    };

  systems = let partition = "systems"; in
    {
      partitions.${partition}.extraInputsFlake = ../partitions/${partition};
    };

  module = {
    imports = [
      inputs.flake-parts.flakeModules.partitions
      pkgs
      systems
    ];
  };
in
module
