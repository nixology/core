{ inputs, lib, ... }:
let
  flake = {
    imports = [
      "${inputs.flake-parts}/modules/transposition.nix"
    ];

    config = {
      transposition = lib.mkOptionDefault { };
    };
  };
in
lib.mkComponent {
  name = lib.basename __curPos.file;

  modules = { inherit flake; };

  dependencies = with inputs.self.components; [
    nixology.core.flake
    nixology.core.perSystem
  ];

  meta = {
    description = "Expose the upstream flake-parts transposition module as a nixology component.";
    shortDescription = "flake-parts transposition component";
  };
}
