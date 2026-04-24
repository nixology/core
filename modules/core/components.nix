{
  config,
  inputs,
  moduleLocation,
  ...
}:
let
  flake-schemas = config.partitions.schemas.extraInputs.flake-schemas;

  module =
    { config, lib, ... }:
    {
      options =
        with lib;
        with types;
        let
          resolveComponentModule =
            {
              domain,
              subdomain,
              component,
            }:
            assert config.flakeref != null || throw "flakeref must not be null";
            if component._resolved == true then
              component
            else
              component
              // {
                _resolved = true;
                module = {
                  key =
                    "${config.flakeref}#components.${domain}.${subdomain}.${component.meta.name}"
                    + lib.optionalString (component.meta.version != null) ".${component.meta.version}";
                  imports = [ component.module ] ++ (map (dependency: dependency.module) component.dependencies);
                  _class = "flake";
                  _file = "${moduleLocation}#components.${domain}.${subdomain}.${component.meta.name}";
                };
              };

          components = mkOption {
            type = lazyAttrsOf (lazyAttrsOf (lazyAttrsOf component));
            default = { };
            description = "A set of reusable components.";
            apply = mapAttrs (
              domain:
              mapAttrs (
                subdomain: mapAttrs (_: component: resolveComponentModule { inherit domain subdomain component; })
              )
            );
          };

          component = submodule (
            { name, ... }:
            {
              options = {
                inherit dependencies meta module;
                _resolved = mkOption {
                  type = bool;
                  default = false;
                  description = "Internal flag. Do not set manually.";
                  visible = false;
                };
              };
              config = {
                meta.name = lib.mkDefault name;
              };
            }
          );

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
                  inherit
                    description
                    name
                    shortDescription
                    version
                    ;
                };
                freeformType = lazyAttrsOf (unique { inherit message; } raw);
              });
              default = { };
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

      config = {
        flake.schemas.components = {
          version = 1;
          doc = ''
            The `components` flake output provides importable components.
          '';
          inventory =
            let
              inherit (flake-schemas.lib) mkChildren;
            in
            output:
            mkChildren (
              builtins.mapAttrs (name: value: {
                children =
                  let
                    recurse =
                      prefix: attrs:
                      builtins.mapAttrs (
                        attrName: attrs:
                        if (lib.isAttrs attrs && (attrs ? module && attrs ? _resolved)) then
                          {
                            what =
                              if ((attrs.meta.shortDescription or null) != null) then
                                "component (${attrs.meta.shortDescription})"
                              else
                                "component";
                          }
                        else
                          {
                            children = recurse (prefix + "." + attrName) attrs;
                          }
                      ) attrs;
                  in
                  recurse name value;
              }) output
            );
        };
      };
    };

  component = {
    inherit module;
    dependencies = with inputs.self.components; [
      nixology.core.schemas
    ];
    meta = {
      description = "Provides a reusable component system for flake modules organized into a structured domain.subdomain.name hierarchy with support for dependencies and metadata";
      shortDescription = "reusable component system for flake modules";
    };
  };

  checks =
    { config, ... }:
    {
      perSystem =
        { pkgs, ... }:
        let
          eval = config.flake.lib.evalFlakeModule null { inherit inputs; } (
            with inputs.self.components; nixology.core.components.module
          );
        in
        {
          checks.core-components = pkgs.runCommandLocal "core-components-check" { } ''
            : ${builtins.seq eval.config "ok"}
            touch $out
          '';
        };
    };
in
{
  imports = [
    checks
    module
  ];
  flake.components = {
    nixology.core.components = component;
  };
}
