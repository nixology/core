{ inputs, lib, ... }:
let
  flake = inputs.flake-parts.flakeModules.touchup;
in
lib.mkComponent {
  name = lib.basename __curPos.file;
  subdomain = "extra";

  modules = { inherit flake; };

  dependencies = with inputs.self.components; [ nixology.core.flake ];

  meta = {
    description = "Controls which flake attributes appear in `processedFlake` and how they are transformed.";
    shortDescription = "controls which flake attributes appear and how they are transformed";
  };
}
