{ inputs, ... }:
let
  module = with inputs.flake-parts.flakeModules; partitions;

  component = {
    inherit module;
    meta = {
      shortDescription = "module for partition management";
    };
  };
in
{
  imports = [ module ];
  flake.components = {
    nixology.core.partitions = component;
  };
}
