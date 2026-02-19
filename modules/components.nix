{ config, inputs, moduleLocation, ... }:
let
  module = { config, lib, ... }: {
    options = with lib; with types; let
      mkComponentModule = { domain, subdomain, name, component }: {
        key = "${config.flake.meta.flakeref}#components.${domain}.${subdomain}.${name}" +
          lib.optionalString (component.version != null) ".${component.version}";
        # conditionally add module config attribute if component has meta attribute
        ${if (component.meta != null) then "config" else null} =
          { flake.meta.components.${domain}.${subdomain}.${name} = component.meta; };
        imports = component.dependencies ++ [ component.module ];
        _class = "flake";
        _file = "${moduleLocation}#components.${domain}.${subdomain}.${name}";
      };

      components = mkOption {
        type = lazyAttrsOf (lazyAttrsOf (lazyAttrsOf component));
        default = { };
        description = "A set of reusable components.";
        apply = mapAttrs (domain: mapAttrs (subdomain: mapAttrs (name: component:
          mkComponentModule { inherit domain subdomain name component; }
        )));
      };

      component = submodule ({ name, ... }: {
        options = {
          inherit dependencies meta module name version;
        };
      });

      dependencies = mkOption {
        type = listOf deferredModule;
        default = [ ];
        description = "A list of other components that this component depends on.";
      };

      meta =
        let
          description = ''
            Metadata about the component.
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
        in
        mkOption {
          type = nullOr (submoduleWith {
            modules = [
              {
                freeformType = lazyAttrsOf (unique { inherit message; } raw);
              }
            ];
          });
          default = null;
          inherit description;
        };

      module = mkOption {
        type = deferredModule;
        description = "The module defining this component.";
      };

      name = mkOption {
        type = nonEmptyStr;
        default = name;
        description = "The name of the component.";
      };

      version = mkOption {
        type = nullOr nonEmptyStr;
        default = null;
        description = "The version of the component.";
      };
    in
    {
      flake = { inherit components; };
    };
  };

  component = {
    inherit module;
    dependencies = with inputs.self; [
      components.nixology.std.meta
    ];
    meta.description = "Provides a reusable component system for organizing flake modules into a structured domain.subdomain.name hierarchy with support for versioning, dependencies, and metadata";
  };
in
{
  imports = [ module ];
  flake.components.nixology.std.components = component;
}
