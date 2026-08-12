{ inputs, lib, ... }:
let
  flake = "${inputs.flake-parts}/modules/withSystem.nix";
in
lib.mkComponent {
  name = lib.basename __curPos.file;

  modules = { inherit flake; };

  meta = {
    description = "Expose the upstream flake-parts withSystem module as a nixology component.";
    shortDescription = "flake-parts withSystem component";
  };
}
