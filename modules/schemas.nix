{ config, lib, ... }:
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

  inputs = config.partitions.schemas.extraInputs;

  inherit (inputs.flake-schemas.lib) mkChildren;

  flake-schemas = inputs.flake-schemas.schemas // {
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
                      if (lib.isAttrs attrs && (attrs ? imports || attrs ? config || attrs ? options)) || lib.isFunction attrs then {
                        what = "component";
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

  schemas = map
    (output:
      let
        module = {
          flake.schemas.${output} = flake-schemas.${output};
        };
      in
      {
        inherit output;
        component = {
          inherit module;
        };
      }
    )
    outputs;
in
{
  imports = [{ flake.schemas = flake-schemas; }];
} //
builtins.foldl' lib.recursiveUpdate { } (map
  (schema: {
    flake.components = { nixology.schemas.${schema.output} = schema.component; };
  })
  schemas)
