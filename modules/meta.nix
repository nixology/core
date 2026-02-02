let
  module =
    { lib, ... }:
    {
      options =
        with lib;
        with types;
        let
          meta = mkOption {
            type = submoduleWith {
              modules = [
                {
                  freeformType = lazyAttrsOf (unique { inherit message; } raw);
                }
                {
                  options = { inherit flakeref; };
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
        in
        {
          flake = { inherit meta; };
        };
    };

  component = {
    inherit module;
  };
in
{
  imports = [ module ];
  flake.components.nixology.std.meta = component;
}
