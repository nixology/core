{ config, lib, ... }:
let
  systems = config.partitions.systems.extraInputs;

  module = {
    # n.b. don't want merge semantics here; exclusively want aarch64 darwin system, so mkForce
    systems = lib.mkForce (import systems.aarch64-darwin);
  };

  component = {
    inherit module;
  };
in
{
  flake.components.nixology.systems.aarch64-darwin = component;
}
