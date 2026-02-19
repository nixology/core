{ config, lib, ... }:
let
  # capture partition inputs from config of outer flake
  # so that is is part of the component
  inputs = config.partitions.systems.extraInputs;

  module = {
    systems = import inputs.default-linux;
  };

  component = {
    inherit module;
  };
in
{
  flake.components.nixology.std.systems-linux = component;
}
