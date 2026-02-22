{ config, lib, ... }:
let
  systems = config.partitions.systems.extraInputs;

  module = {
    # n.b. don't want merge semantics here; exclusively want x86_64 darwin system, so mkForce
    systems = lib.mkForce (import systems.x86_64-darwin);
  };

  component = {
    inherit module;
  };
in
{
  flake.components.nixology.systems.x86_64-darwin = component;
}
