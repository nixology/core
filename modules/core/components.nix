{
  config,
  inputs,
  lib,
  ...
}:
let
  inherit (config) flakeref;

  inherit (inputs.self.components) nixology;

  inherit (lib)
    isAttrs
    mkDefault
    mkOption
    optionalString
    ;

  inherit (lib.components) evalComponent;

  inherit (lib.types)
    addCheck
    deferredModule
    lazyAttrsOf
    listOf
    nonEmptyStr
    nullOr
    raw
    submodule
    unique
    ;

  moduleLocation = "${inputs.self.outPath}/flake.nix";

  flake =
    args:
    let
      undeclaredMetaMessage = ''
        No option has been declared for this attribute, so its definitions can't be merged automatically.
        Possible solutions:
          - Load a module that defines this attribute
          - Declare an option for this attribute
          - Make sure the attribute is spelled correctly
          - Define the value only once, with a single definition in a single module
      '';

      isComponent = value: isAttrs value && value ? module && value.module != null;

      componentRefType = addCheck raw isComponent;

      componentType =
        { domain, subdomain }:
        submodule (
          { config, name, ... }:
          {
            options = {
              dependencies = mkOption {
                type = listOf componentRefType;
                default = [ ];
                description = "A list of other components that this component depends on.";
              };

              meta = mkOption {
                type = nullOr (submodule {
                  options = {
                    name = mkOption {
                      type = nonEmptyStr;
                      default = name;
                      description = "The name of the component.";
                    };

                    description = mkOption {
                      type = nullOr nonEmptyStr;
                      default = null;
                      description = "A description of the component.";
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
                  };

                  freeformType = lazyAttrsOf (
                    unique {
                      message = undeclaredMetaMessage;
                    } raw
                  );
                });

                default = { };
                description = "Metadata about the component.";
              };

              implementation = mkOption {
                type = deferredModule;
                description = "The module defining this component.";
              };

              module = mkOption {
                type = deferredModule;
                readOnly = true;
                description = "The fully resolved component module including dependencies.";
                apply =
                  _:
                  lib.throwIfNot (flakeref != null)
                    (
                      "nixology: `flakeref` must be set before components can be used. "
                      + "Add `flakeref = \"github:your-org/your-repo\";` to your flake module."
                    )
                    {
                      key =
                        "${flakeref}#components.${domain}.${subdomain}.${config.meta.name}"
                        + optionalString (config.meta.version != null) ".${config.meta.version}";

                      imports = [
                        config.implementation
                      ]
                      ++ map (dependency: dependency.module) config.dependencies;

                      _class = "flake";
                      _file = "${moduleLocation}#components.${domain}.${subdomain}.${config.meta.name}";
                    };
              };
            };

            config = {
              meta.name = mkDefault name;
            };
          }
        );

      subdomainType =
        domain:
        submodule (
          { name, ... }:
          {
            freeformType = lazyAttrsOf (componentType {
              inherit domain;
              subdomain = name;
            });
          }
        );

      domainType = submodule (
        { name, ... }:
        {
          freeformType = lazyAttrsOf (subdomainType name);
        }
      );

      componentsFrom =
        attrs:
        let
          go =
            path: attrs:
            builtins.concatLists (
              builtins.attrValues (
                builtins.mapAttrs (
                  name: value:
                  let
                    newPath = path ++ [ name ];
                  in
                  if builtins.isAttrs value then
                    if isComponent value then
                      [
                        {
                          name = builtins.concatStringsSep "." newPath;
                          inherit value;
                        }
                      ]
                    else
                      go newPath value
                  else
                    [ ]
                ) attrs
              )
            );
        in
        go [ ] attrs;
    in
    {
      options = {
        flake.components = mkOption {
          type = lazyAttrsOf domainType;
          default = { };
          description = "A set of reusable components.";
        };
      };

      config = {
        perSystem = { pkgs, ... }: {
          checks =
            let
              configs = builtins.listToAttrs (
                map ({ name, value }: {
                  inherit name;
                  value = (evalComponent { inherit (args) inputs; } value).config;
                }) (componentsFrom args.config.flake.components)
              );

              inherit (evalComponent { inherit (args) inputs; } nixology.core.components) config;
            in
            {
              components = pkgs.runCommandLocal "checks" (builtins.mapAttrs (
                _: config: builtins.seq config "ok"
              ) configs) "touch $out";

              nixology-core-components = pkgs.runCommandLocal "checks" {
                check_flake_components = builtins.seq config.flake.components "ok";
              } "touch $out";
            };
        };

        flake.schemas = { inherit (config.flake.exportedSchemas) components; };
      };
    };
in
lib.mkComponent {
  name = lib.basename __curPos.file;

  modules = { inherit flake; };

  dependencies = [
    nixology.core.flake
    nixology.core.perSystem
    nixology.core.schemas
  ];

  meta = {
    shortDescription = "reusable component system for modules";
    description = ''
      Provides a reusable component system for modules organized into a
      structured domain.subdomain.name hierarchy with support for dependencies
      and metadata.
    '';
  };
}
