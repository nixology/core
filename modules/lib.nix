{ config ? null, inputs, lib ? inputs.flake-parts.inputs.nixpkgs-lib.lib, ... }:
let
  pkgs = config.partitions.channels-unstable.extraInputs;
  systems = config.partitions.systems.extraInputs;
  flake-parts-lib = inputs.flake-parts.lib;

  defaultModule =
    {
      imports = [
        #        "${inputs.flake-parts}/modules/apps.nix"
        #        "${inputs.flake-parts}/modules/checks.nix"
        #"${inputs.flake-parts}/modules/debug.nix"
        #        "${inputs.flake-parts}/modules/devShells.nix"
        "${inputs.flake-parts}/modules/flake.nix"
        #        "${inputs.flake-parts}/modules/formatter.nix"
        #        "${inputs.flake-parts}/modules/legacyPackages.nix"
        #        "${inputs.flake-parts}/modules/moduleWithSystem.nix"
        #        "${inputs.flake-parts}/modules/nixosConfigurations.nix"
        #        "${inputs.flake-parts}/modules/nixosModules.nix"
        "${inputs.flake-parts}/modules/nixpkgs.nix"
        #        "${inputs.flake-parts}/modules/overlays.nix"
        #        "${inputs.flake-parts}/modules/packages.nix"
        "${inputs.flake-parts}/modules/perSystem.nix"
        #        "${inputs.flake-parts}/modules/transposition.nix"
        #        "${inputs.flake-parts}/modules/withSystem.nix"
      ];

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
          modules = [ (lib.setDefaultModuleLocation errorLocation module) ];
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
              defaultModule
              nixology.std.meta.module
            ]);
          };
          #eval = inputs.flake-parts.lib.evalFlakeModule args module;
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
      inherit mkFlake mkTOMLFlake modulesIn;
    };

  module = { flake.lib = lib.mkDefault library; };

  component = {
    inherit module;
    dependencies = with inputs.self.components; [
      nixology.schemas.lib
    ];
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
