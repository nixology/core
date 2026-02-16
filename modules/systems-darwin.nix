{ config, lib, ... }:
let
  # capture partition inputs from config of outer flake
  # so that is is part of the component
  inputs = config.partitions.default.extraInputs;

  module = {
    systems = lib.mkDefault (import inputs.systems-darwin);
  };

  component = {
    inherit module;
  };
in
{
  flake.components.nixology.std.systems-darwin = component;
}
