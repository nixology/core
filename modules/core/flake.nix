{ lib, inputs, ... }:
let
  flake = "${inputs.flake-parts}/modules/flake.nix";
in
lib.mkComponent {
  name = lib.basename __curPos.file;

  modules = { inherit flake; };

  meta = {
    description = "Expose the upstream flake-parts flake module as a nixology component.";
    shortDescription = "flake-parts flake component";
  };
}
