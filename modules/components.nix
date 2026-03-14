{ config, inputs, moduleLocation, ... }:
let
  module = { config, lib, ... }: {
    options = with lib; with types; let
      resolveComponentModule = { domain, subdomain, component }:
        if component._resolved == true then component
        else component // {
          _resolved = true;
          module = {
            key = "${config.flake.meta.flakeref}#components.${domain}.${subdomain}.${component.meta.name}" +
              lib.optionalString (component.meta.version != null) ".${component.meta.version}";
            imports = [ component.module ] ++ (builtins.map (dependency: dependency.module) component.dependencies);
            _class = "flake";
            _file = "${moduleLocation}#components.${domain}.${subdomain}.${component.meta.name}";
          };
        };

      components = mkOption {
        type = lazyAttrsOf (lazyAttrsOf (lazyAttrsOf component));
        default = { };
        description = "A set of reusable components.";
        apply = mapAttrs (domain: mapAttrs (subdomain: mapAttrs (_: component:
          resolveComponentModule { inherit domain subdomain component; }
        )));
      };

      component = submodule ({ name, ... }: {
        options = {
          inherit dependencies meta module;
          _resolved = mkOption { type = bool; default = false; };
        };
        config = {
          meta.name = lib.mkDefault name;
        };
      });

      dependencies = mkOption {
        type = listOf component;
        default = [ ];
        description = "A list of other components that this component depends on.";
      };

      description = mkOption {
        type = nullOr nonEmptyStr;
        default = null;
        description = "A description of the component.";
      };

      name = mkOption {
        type = nonEmptyStr;
        default = name;
        description = "The name of the component.";
      };

      meta =
        let
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
          type = nullOr (submodule {
            options = {
              inherit description name shortDescription version;
            };
            freeformType = lazyAttrsOf (unique { inherit message; } raw);
          });
          default = null;
          description = ''
            Metadata about the component. Any attribute can be set here, but some attributes
            are represented by options, to provide appropriate configuration merging.
          '';
        };

      module = mkOption {
        type = deferredModule;
        description = "The module defining this component.";
      };

      shortDescription = mkOption {
        type = nullOr nonEmptyStr;
        default = null;
        description = "A short description of the component.";
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
    dependencies = with inputs.self.components; [
      nixology.std.meta
    ];
    meta = {
      description = "Provides a reusable component system for flake modules organized into a structured domain.subdomain.name hierarchy with support for dependencies and metadata";
      shortDescription = "reusable component system for flake modules";
    };
  };
in
{
  imports = [ module ];
  flake.components = { nixology.std.components = component; };
}
