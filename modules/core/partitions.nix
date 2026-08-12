{ inputs, lib, ... }:
let
  flake = inputs.flake-parts.flakeModules.partitions;
in
lib.mkComponent {
  name = lib.basename __curPos.file;

  modules = { inherit flake; };

  dependencies = with inputs.self.components; [ nixology.core.flake ];

  meta = {
    description = "Expose the upstream flake-parts partitions module as a nixology component.";
    shortDescription = "partition management module";
  };
}
