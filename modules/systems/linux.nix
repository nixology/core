{ config, lib, ... }:
let
  systems = config.partitions.systems.extraInputs;

  module = {
    # n.b. don't want merge semantics here; exclusively want linux systems, so mkForce
    systems = lib.mkForce (import systems.default-linux);
  };

  component = {
    inherit module;
  };
in
{
  flake.components.nixology.systems.linux = component;
}
