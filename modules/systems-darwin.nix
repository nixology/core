{ config, ... }:
let
  systems = config.partitions.systems.extraInputs;

  module = {
    systems = import systems.default-darwin;
  };

  component = {
    inherit module;
  };
in
{
  flake.components.nixology.systems.darwin = component;
}
