{ inputs, lib, ... }:
let
  flake = "${inputs.flake-parts}/modules/perSystem.nix";
in
lib.mkComponent {
  name = lib.basename __curPos.file;

  modules = { inherit flake; };

  meta = {
    description = "Expose the upstream flake-parts perSystem module as a nixology component.";
    shortDescription = "flake-parts perSystem component";
  };
}
