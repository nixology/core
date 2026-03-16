{ config, inputs, lib, ... }:
let
  outputs = [
    "apps"
    "bundlers"
    "checks"
    "darwinConfigurations"
    "darwinModules"
    "devShells"
    "formatter"
    "homeConfigurations"
    "homeModules"
    "hydraJobs"
    "legacyPackages"
    "nixosConfigurations"
    "nixosModules"
    "ociImages"
    "overlays"
    "packages"
    "schemas"
    "templates"
  ] ++ [
    "allSystems"
    "debug"
  ] ++ [
    "components"
    "lib"
    "meta"
  ];

  extraInputs = config.partitions.schemas.extraInputs;

  inherit (extraInputs.flake-schemas.lib) mkChildren;

  flake-schemas = extraInputs.flake-schemas.schemas // {
    allSystems = {
      version = 1;
      doc = ''
        The `allSystems` flake output provides the perSystem flake-parts configuration.
        An attribute set of configured systems, each consisting of the `perSystem` attributes, plus the extra attributes `_module`, `config`, `options`, `extendModules`.
        N.B. these are not part of the `config` parameter, but are merged in for debugging convenience.
      '';
      inventory =
        output: mkChildren (
          builtins.mapAttrs
            (name: value: {
              what = "perSystem flake-parts configuration";
            })
            output
        );
    };

    debug = {
      version = 1;
      doc = ''
        The `debug` flake output provides the top-level flake-parts configuration.
        An attribute set consisting of the `config` attributes, plus the extra attributes `_module`, `config`, `options`, `extendModules`.
        N.B. these are not part of the `config` parameter, but are merged in for debugging convenience.
      '';
      inventory = output: { what = "top-level flake-parts configuration"; };
    };

    components = {
      version = 1;
      doc = ''
        The `components` flake output provides importable components.
      '';
      inventory =
        output: mkChildren (
          builtins.mapAttrs
            (name: value: {
              children =
                let
                  recurse = prefix: attrs: builtins.mapAttrs
                    (attrName: attrs:
                      if (lib.isAttrs attrs && (attrs ? module && attrs ? _resolved)) then {
                        what =
                          if (attrs ? meta && attrs.meta ? shortDescription && attrs.meta.shortDescription != null)
                          then "component (${attrs.meta.shortDescription})"
                          else "component";
                      }
                      else {
                        children = recurse (prefix + "." + attrName) attrs;
                      }
                    )
                    attrs;
                in
                recurse name value;
            })
            output
        );
    };

    currentSystem = {
      version = 1;
      doc = ''
        The `currentSystem` flake output provides the perSystem flake-parts configuration for the current system.
        An attribute set consisting of the `perSystem` attributes, plus the extra attributes `_module`, `config`, `options`, `extendModules`.
        N.B. these are not part of the `config` parameter, but are merged in for debugging convenience.
        Only avaiable in impure mode.
      '';
      inventory = output: { what = "perSystem flake-parts configuration for ${output.allModuleArgs.system}"; };
    };

    lib = {
      version = 1;
      doc = ''
        The `lib` flake output provides a collection of functions.
      '';
      inventory =
        output: mkChildren (
          builtins.mapAttrs
            (name: value: {
              what = if builtins.isFunction value then "library function" else "library value";
            })
            output
        );
    };

    meta = {
      version = 1;
      doc = ''
        The `meta` flake output provides metadata about the flake.
      '';
      inventory = output: mkChildren (builtins.mapAttrs
        (name: value:
          {
            what = "${if name == "components" then "metadata for components defined in the flake" else
            if ! builtins.isAttrs value then value else "attribute set" }";
          })
        output);
    };
  };

  module = { lib, ... }: {
    options = with lib; with types;
      {
        flake.schemas = mkOption {
          type = lazyAttrsOf (lazyAttrsOf anything);
          default = { };
          description = "Schemas for flake output types.";
        };
      };
  };

  component = {
    inherit module;
  };

  schemas = builtins.listToAttrs (map
    (output:
      let
        module = {
          flake.schemas.${output} = flake-schemas.${output};
        };
      in
      {
        name = output;
        value = {
          inherit module;
          dependencies = with inputs.self.components; [
            nixology.std.schemas
          ];
          meta = {
            shortDescription = "flake schema";
          };
        };
      }
    )
    outputs);
in
{
  imports = [
    module
    schemas.allSystems.module
    schemas.components.module
    schemas.debug.module
    schemas.lib.module
    schemas.meta.module
    schemas.schemas.module
  ];
} //
{
  flake.components = { nixology.std.schemas = component; };
  flake.components = { nixology.schemas = schemas; };
}
