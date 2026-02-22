{ config, ... }:
let
  systems = config.partitions.systems.extraInputs;

  module = {
    systems = import systems.default;
  };

  component = {
    inherit module;
  };
in
{
  flake.components.nixology.systems.default = component;
}
