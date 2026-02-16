main@{ config, inputs, ... }:
let
  flake-parts-lib = main.inputs.flake-parts.lib;

  module =
    { lib, ... }:
    let
      library =
        let
          mkFlake =
            flakeArgs@{ flakeref, ... }:
            flakeModule:
            let
              args = builtins.removeAttrs flakeArgs [ "flakeref" ];
              module = {
                imports = [
                  flakeModule
                  config.partitions.default.module;
                ];
              };
            in
            flake-parts-lib.mkFlake args {
              imports = [
                module
                { flake.meta.flakeref = flakeref; }
              ];
            };

          mkTOMLFlake =
            flakeArgs: tomlFile:
            let
              toml = builtins.fromTOML (builtins.readFile tomlFile);
              args = flakeArgs // {
                inherit (toml.flake) flakeref;
              };
              source = lib.lists.head toml.sources;
              name = lib.lists.last (lib.strings.split "/" source.url);
              component = lib.lists.head source.components;
              input = "${name}.components.${component}";
              module = lib.getAttrFromPath (lib.strings.splitString "." input) flakeArgs.inputs;
            in
            mkFlake args module;

          modulesIn =
            directory:
            with lib;
            let
              moduleFiles =
                if filesystem.pathIsDirectory directory then
                  (filter (n: strings.hasSuffix ".nix" n) (filesystem.listFilesRecursive directory))
                else
                  [ ];
            in
            moduleFiles;
        in
        {
          inherit mkFlake mkTOMLFlake modulesIn;
        };
    in
    {
      options =
        with lib;
        with types;
        {
          flake.lib = mkOption {
            type = attrsOf (functionTo anything);
            default = { };
            description = "A set of utility functions and definitions.";
          };
        };

      config.flake.lib = lib.mkDefault library;
    };

  component = {
    inherit module;
  };
in
{
  imports = [ module ];
  flake.components.nixology.std.lib = component;
}
