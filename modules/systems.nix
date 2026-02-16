{ config, lib, ... }:
let
  # capture partition inputs from config of outer flake
  # so that is is part of the component
  inputs = config.partitions.default.extraInputs;
in
{
  systems = lib.mkDefault (import inputs.systems);
}
