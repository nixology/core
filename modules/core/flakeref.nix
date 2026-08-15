{ lib, ... }:
let
  flake = {
    options = {
      flakeref = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "The flake reference for this flake.";
      };
    };
  };
in
lib.mkComponent {
  name = lib.basename __curPos.file;

  modules = { inherit flake; };

  meta = {
    description = "Provide a unique identifier for the flake.";
    shortDescription = "flake reference option";
  };
}
