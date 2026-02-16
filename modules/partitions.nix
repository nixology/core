{ inputs, ... }:
let
  default = let partition = "default"; in
    {
      imports = [ inputs.flake-parts.flakeModules.partitions ];
      partitions.${partition}.extraInputsFlake = ../partitions/${partition};
    };

  module = default;
in
module
