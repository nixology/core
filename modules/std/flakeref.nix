{ config, inputs, ... }:
let
  module = { lib, ... }: {
    options = with lib; with types; let
      flakeref = mkOption {
        type = nullOr str;
        description = "The flake reference for this flake.";
        default = null;
      };
    in
    {
      inherit flakeref;
    };
  };

  component = {
    inherit module;
    meta = {
      description = "Provides a unique identifier for the flake.";
    };
  };
in
{
  imports = [ module ];
  flake.components = { nixology.std.flakeref = component; };
}
