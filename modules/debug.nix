{ inputs, lib, ... }: let
  module = {
    imports = [
      "${inputs.flake-parts}/modules/debug.nix"
    ];
    debug = lib.mkDefault true;
  };

  component = {
    inherit module;
    dependencies = with inputs.self.components; [
      nixology.schemas.debug
      nixology.schemas.allSystems
    ];
    meta = {
      description = "Expose debug attributes for the flake.";
      shortDescription = "expose debug attributes for the flake";
    };
  };
in {
  imports = [ module ];
  flake.components = { nixology.std.debug = component; };
}
