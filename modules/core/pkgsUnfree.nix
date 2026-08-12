{ inputs, lib, ... }:
let
  flake = {
    pkgs.settings.allowUnfree = true;
  };
in
lib.mkComponent {
  name = lib.basename __curPos.file;

  modules = { inherit flake; };

  dependencies = with inputs.self.components; [ nixology.core.pkgs ];

  meta = {
    description = "Enable unfree packages in the nixpkgs `pkgs` instance.";
    shortDescription = "enable unfree packages in pkgs";
  };
}
