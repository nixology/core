{ inputs, moduleLocation, ... }:
let
  module = { config, lib, ... }: {
    options = with lib; with types; let
      components = mkOption {
        type = lazyAttrsOf (lazyAttrsOf (lazyAttrsOf component));

        default = { };

        description = "A set of reusable components.";

        apply = mapAttrs (domain: subdomains:
          mapAttrs
            (subdomain: components:
              mapAttrs
                (name: component:
                  # if already a component, then pass it through (this is mainly for aggregating components from other flakes)
                  if component ? key && lib.hasInfix "components" component.key
                  then builtins.trace "already component" {
                    inherit (component) key imports _class _file;
                  }
                  # otherwise assume it's a module and wrap it in a component
                  else {
                    key = "${config.flake.meta.flakeref}#components.${domain}.${subdomain}.${name}";
                    imports = [ component.module ] ++ component.dependencies;
                    _class = "flake";
                    _file = "${moduleLocation}#components.${domain}.${subdomain}.${name}";
                  })
                components
            )
            subdomains
        );
      };

      component = submodule ({ name, ... }: {
        options = {
          inherit name version module dependencies;
        };
      });

      name = mkOption {
        type = str;
        default = name;
        description = "The name of the component.";
      };

      version = mkOption {
        type = str;
        description = "The version of the component.";
      };

      module = mkOption {
        type = deferredModule;
        description = "The module defining this component.";
      };

      dependencies = mkOption {
        type = listOf deferredModule;
        default = [ ];
        description = "A list of other components that this component depends on.";
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
  };
in
{
  imports = [ module ];
  flake.components.nixology.std.components = component;
}
