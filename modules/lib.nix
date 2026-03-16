{ config ? null, inputs, lib ? inputs.flake-parts.inputs.nixpkgs-lib.lib, ... }:
let
  flake-schemas = config.partitions.schemas.extraInputs.flake-schemas;

  nixpkgs = config.partitions.channels-unstable.extraInputs.nixpkgs;
  systems = config.partitions.systems.extraInputs.default;

  flake-parts-lib = inputs.flake-parts.lib;

  defaultModule =
    {
      imports = [
        "${inputs.flake-parts}/modules/flake.nix"
        "${inputs.flake-parts}/modules/moduleWithSystem.nix"
        "${inputs.flake-parts}/modules/nixpkgs.nix"
        "${inputs.flake-parts}/modules/perSystem.nix"
        "${inputs.flake-parts}/modules/transposition.nix"
        "${inputs.flake-parts}/modules/withSystem.nix"
      ];

      # default pkgs
      perSystem = { system, ... }:
        {
          _module.args.pkgs = lib.mkDefault (builtins.seq nixpkgs nixpkgs.legacyPackages.${system});
        };

      # default systems
      systems = lib.mkDefault (import systems);

      # default transposed attributes
      transposition = lib.mkOptionDefault { };
    };

  library =
    let
      evalFlakeModule =
        args@
        { inputs
        , specialArgs ? { }
        , self ? inputs.self
        , moduleLocation ? "${self.outPath}/flake.nix"
        }:
        let
          inputsPos = builtins.unsafeGetAttrPos "inputs" args;
          errorLocation =
            # Best case: user makes it explicit
            args.moduleLocation or (
              # Slightly worse: Nix does not technically commit to unsafeGetAttrPos semantics
              if inputsPos != null
              then inputsPos.file
              # Slightly worse: self may not be valid when an error occurs
              else if args?inputs.self.outPath
              then args.inputs.self.outPath + "/flake.nix"
              # Fallback
              else "<mkFlake argument>"
            );
        in
        (module:
        lib.evalModules {
          specialArgs = {
            inherit self flake-parts-lib moduleLocation;
            inputs = args.inputs;
          } // specialArgs;
          modules = [ (lib.setDefaultModuleLocation errorLocation module) ] ++
            lib.optionals (config != null) [ defaultModule ];
          class = "flake";
        }
        );

      mkFlake = flakeArgs@{ flakeref, ... }: flakeModule:
        let
          args = builtins.removeAttrs flakeArgs [ "flakeref" ];
          module = {
            imports = [
              flakeModule
              { flake.meta.flakeref = flakeref; }
            ] ++ lib.optionals (config != null) (with inputs.self.components; [
              nixology.std.meta.module
            ]);
          };
          eval = evalFlakeModule args module;
        in
        eval.config.flake;

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
      inherit evalFlakeModule mkFlake mkTOMLFlake modulesIn;
    };

  schema = {
    version = 1;
    doc = ''
      The `lib` flake output provides a collection of functions.
    '';
    inventory = let inherit (flake-schemas.lib) mkChildren; in
      output: mkChildren (
        builtins.mapAttrs
          (name: value: {
            what = if builtins.isFunction value then "library function" else "library value";
          })
          output
      );
  };

  module = {
    flake.lib = lib.mkDefault library;
    flake.schemas.lib = schema;
  };

  component = {
    inherit module;
    dependencies = with inputs.self.components; [
      nixology.std.schemas
    ];
    meta = {
      shortDescription = "library of functions for nixology methodology";
    };
  };
in
{
  imports = [ defaultModule ];

  flake.lib = library;
  flake.schemas.lib = schema;

  flake.components = { nixology.std.lib = component; };
}
