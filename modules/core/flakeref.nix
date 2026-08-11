{ lib, ... }:
let
  flake = {
    options =
      with lib;
      with types;
      {
        flakeref = mkOption {
          type = nullOr str;
          default = null;
          description = "The flake reference for this flake.";
        };
      };
  };
in
lib.mkComponent __curPos.file {
  modules = { inherit flake; };
  meta = {
    description = "Provide a unique identifier for the flake.";
    shortDescription = "flake reference option";
  };
}
