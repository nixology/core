{ config ? null, inputs, lib ? inputs.flake-parts.inputs.nixpkgs-lib.lib, ... }:
let
  pkgs = config.partitions.channels-unstable.extraInputs;
  systems = config.partitions.systems.extraInputs;

  defaultModule =
    {
      # default systems
      systems = lib.mkDefault (import systems.default);

      # default pkgs
      perSystem = { system, ... }:
        {
          _module.args.pkgs = lib.mkDefault (builtins.seq pkgs.nixpkgs pkgs.nixpkgs.legacyPackages.${system});
        };
    };

  library =
    let
      mkFlake = flakeArgs@{ flakeref, ... }: flakeModule:
        let
          args = builtins.removeAttrs flakeArgs [ "flakeref" ];
          module = {
            imports = [
              flakeModule
              { flake.meta.flakeref = flakeref; }
            ] ++ lib.optionals (config != null) (with inputs.self.components; [
              defaultModule
              nixology.std.meta.module
            ]);
          };
        in
        inputs.flake-parts.lib.mkFlake args module;

      mkTOMLFlake = flakeArgs: tomlFile:
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

      modulesIn = directory: with lib; let
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

  module = { flake.lib = lib.mkDefault library; };

  component = {
    inherit module;
    meta = {
      shortDescription = "library of functions for nixology methodology";
    };
  };
in
{
  imports = [ defaultModule ];
  flake.lib = library;
  flake.components = { nixology.std.lib = component; };
}
