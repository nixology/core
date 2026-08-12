{ inputs, lib, ... }:
lib.mkComponent {
  name = lib.basename __curPos.file;
  dependencies = with inputs.self.components; [
    nixology.core.flake
    nixology.core.flakeref
    nixology.core.moduleClasses
    nixology.core.moduleWithSystem
    nixology.core.perSystem
    nixology.core.pkgs
    nixology.core.transposition
    nixology.core.withSystem
    nixology.systems.default
  ];
  meta = {
    description = "Default module for nixology.";
    shortDescription = "default module for nixology";
  };
}
