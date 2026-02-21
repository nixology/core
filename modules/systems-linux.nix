{ config, ... }:
let
  systems = config.partitions.systems.extraInputs;

  module = {
    systems = import systems.default-linux;
  };

  component = {
    inherit module;
  };
in
{
  flake.components.nixology.std.systems-linux = component;
}
