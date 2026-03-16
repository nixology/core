{ inputs, ... }:
let
  module = { lib, ... }: {
    options = with lib; with types; let
      meta = mkOption {
        type = submodule {
          options = { inherit flakeref; };
          freeformType = lazyAttrsOf (unique { inherit message; } raw);
        };
        description = "Metadata about the flake.";
      };

      message = ''
        No option has been declared for this attribute, so its definitions can't be merged automatically.
        Possible solutions:
          - Load a module that defines this attribute
          - Declare an option for this attribute
          - Make sure the attribute is spelled correctly
          - Define the value only once, with a single definition in a single module
      '';

      flakeref = mkOption {
        type = str;
        description = "The flake reference for this flake.";
      };
    in
    {
      flake = { inherit meta; };
    };
  };

  component = {
    inherit module;
    dependencies = with inputs.self.components; [
      nixology.schemas.meta
    ];
    meta = {
      description = "Provides metadata infrastructure for flakes, including flakeref tracking.";
      shortDescription = "metadata infrastructure for flakes";
    };
  };
in
{
  imports = [ module ];
  flake.components = { nixology.std.meta = component; };
}
