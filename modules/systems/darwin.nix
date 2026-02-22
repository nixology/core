{ config, lib, ... }:
let
  systems = config.partitions.systems.extraInputs;

  module = {
    # n.b. don't want merge semantics here; exclusively want darwin systems, so mkForce
    systems = lib.mkForce (import systems.default-darwin);
  };

  component = {
    inherit module;
  };
in
{
  flake.components.nixology.systems.darwin = component;
}
