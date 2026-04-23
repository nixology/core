{
  config,
  inputs,
  lib,
  ...
}:
let
  systems = config.partitions.systems.extraInputs.default;

  module = {
    systems = lib.mkDefault (import systems);
  };

  component = {
    inherit module;
    meta = {
      shortDescription = "default systems";
    };
  };
in
{
  imports = [ module ];
  flake.components = {
    nixology.core.systems = component;
  };
}
