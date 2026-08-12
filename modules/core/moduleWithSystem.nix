{ inputs, lib, ... }:
let
  flake = "${inputs.flake-parts}/modules/moduleWithSystem.nix";
in
lib.mkComponent {
  name = lib.basename __curPos.file;

  modules = { inherit flake; };

  dependencies = with inputs.self.components; [ nixology.core.perSystem ];

  meta = {
    description = "Expose the upstream flake-parts moduleWithSystem module as a nixology component.";
    shortDescription = "flake-parts moduleWithSystem component";
  };
}
