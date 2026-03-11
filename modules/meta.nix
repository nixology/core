let
  module = { lib, ... }: {
    options = with lib; with types; let
      meta = mkOption {
        type = submoduleWith {
          modules = [
            {
              freeformType = lazyAttrsOf (unique { inherit message; } raw);
            }
            {
              options = { inherit components flakeref; };
            }
          ];
        };
        inherit description;
      };

      description = ''
        Metadata about the flake.
        Raw attributes. Any attribute can be set here, but some
        attributes are represented by options, to provide appropriate
        configuration merging.
      '';

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

      components = mkOption {
        type = lazyAttrsOf (lazyAttrsOf (lazyAttrsOf anything));
        default = { };
        description = "A set of reusable components.";
      };
    in
    {
      flake = { inherit meta; };
    };
  };

  component = {
    inherit module;
    meta.description = "Provides metadata infrastructure for flakes, including flakeref tracking and component registry with freeform attributes and structured options for extensible flake metadata";
  };
in
{
  imports = [ module ];
  flake.components = { nixology.std.meta = component; };
}
