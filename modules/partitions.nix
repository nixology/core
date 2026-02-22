{ inputs, ... }:
let
  channels = let partition = "channels"; in
    {
      partitions.${partition}.extraInputsFlake = ../partitions/${partition};
    };

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
      channels
      pkgs
      systems
    ];
  };
in
module
