{
  config ? null,
  lib ? local.inputs.nixpkgs.lib,
  ...
}@local:
let
  inherit (local.inputs.self.components) nixology;

  inherit (lib)
    all
    assertMsg
    extend
    filter
    getAttrFromPath
    makeExtensible
    mkDefault
    optional
    optionals
    setDefaultModuleLocation
    ;

  inherit (lib.components) evalComponent;

  inherit (lib.filesystem)
    pathIsDirectory
    listFilesRecursive
    ;

  inherit (lib.lists)
    head
    last
    ;

  inherit (lib.strings)
    hasSuffix
    splitString
    ;

  library =
    let
      flake-parts-lib = import "${local.inputs.flake-parts}/lib.nix" {
        lib = extend (final: prev: library);
        builtinModules = { };
        extraModules = { };
      };

      inherit (flake-parts-lib)
        evalFlakeModule
        ;

      basename =
        url:
        let
          components = splitString "/" url;
          filename = lib.last components;
          parts = splitString "." filename;
        in
        head parts;

      uses =
        {
          components ? [ ],
          ...
        }:
        {
          imports = map (component: component.module) components;
        };

      modulesIn =
        directory:
        if pathIsDirectory directory then
          filter (path: hasSuffix ".nix" path) (listFilesRecursive directory)
        else
          [ ];

      evalComponent = args: component: evalFlakeModule args component.module;

      mkComponent =
        nameOrSource:
        {
          modules ? { },
          dependencies ? [ ],
          domain ? null,
          subdomain ? null,
          meta ? { },
        }:
        let
          implementation =
            {
              config,
              lib,
              ...
            }@args:
            let
              inherit (config) flakeref;

              componentName = basename nameOrSource;

              flakerefComponents =
                let
                  match = builtins.match "([a-zA-Z0-9+.-]+):([^/]+)/([^/?#]+)(/([^?#]+))?(\\?.*)?" flakeref;
                in
                if flakeref == null || match == null then
                  null
                else
                  {
                    forge = builtins.elemAt match 0;
                    owner = builtins.elemAt match 1;
                    repo = builtins.elemAt match 2;
                    ref = builtins.elemAt match 4;
                  };

              componentDomain =
                if domain != null then
                  domain
                else if flakerefComponents != null then
                  flakerefComponents.owner
                else
                  abort "Unable to determine component domain.";

              componentSubdomain =
                if subdomain != null then
                  subdomain
                else if flakerefComponents != null then
                  basename flakerefComponents.repo
                else
                  abort "Unable to determine component subdomain.";

              featureModule = modules.flake or null;
              targetModules = removeAttrs modules [ "flake" ];

              featureTargetsModule =
                if builtins.attrNames targetModules == [ ] then
                  null
                else
                  {
                    flake.modules = builtins.mapAttrs (class: module: {
                      ${componentName} = {
                        key = "${flakeref}#components.${componentName}";
                        imports = [ module ];
                      };
                    }) targetModules;
                  };

              module = {
                imports =
                  optional (featureModule != null) featureModule
                  ++ optional (featureTargetsModule != null) featureTargetsModule;
              };
            in
            {
              imports = [ module ];

              flake.components.${componentDomain}.${componentSubdomain}.${componentName} = {
                implementation = module;
                dependencies = dependencies ++ [
                  nixology.core.modules
                  nixology.core.components
                ];
                inherit meta;
              };
            };
        in
        {
          imports = [ implementation ];
        };

      mkFlake =
        args: module:
        flake-parts-lib.mkFlake args {
          imports = [ module ] ++ optionals (config != null) [ nixology.core.default.module ];
        };

      mkTOMLFlake =
        flakeArgs: tomlFile:
        let
          toml = builtins.fromTOML (builtins.readFile tomlFile);
          source = head toml.sources;

          name = last (splitString "/" source.url);
          componentName = head source.components;

          componentPath = splitString "." "${name}.components.${componentName}";
          module = getAttrFromPath componentPath flakeArgs.inputs;

          args = flakeArgs // {
            inherit (toml.flake) flakeref;
          };
        in
        mkFlake args module;

      metadataForFlakeInput =
        flake: input:
        let
          lock = builtins.fromJSON (builtins.readFile "${flake.outPath}/flake.lock");

          inputName =
            input:
            builtins.head (
              builtins.filter (name: flake.inputs.${name} == input) (builtins.attrNames flake.inputs)
            );

          getNode = input: lock.nodes.${inputName input};
          locked = input: (getNode input).locked;
          original = input: (getNode input).original;

          ref = input: (original input).ref or null;
          rev = input: (locked input).rev or null;
          url = input: (locked input).url or null;

          version =
            input:
            let
              ref' = ref input;
            in
            if ref' == null then
              null
            else if builtins.substring 0 1 ref' == "v" then
              builtins.substring 1 (builtins.stringLength ref' - 1) ref'
            else
              ref';
        in
        {
          pname = inputName input;
          inherit input;
          src = input;
          ref = ref input;
          rev = rev input;
          url = url input;
          version = version input;
        };
    in
    {
      inherit
        basename
        evalComponent
        metadataForFlakeInput
        mkComponent
        mkFlake
        mkTOMLFlake
        modulesIn
        ;
      components = {
        inherit
          evalComponent
          mkComponent
          uses
          ;
      };
      flake = {
        inherit
          metadataForFlakeInput
          mkFlake
          mkTOMLFlake
          ;
      };
      parts = {
        inherit (flake-parts-lib)
          defaultModule
          evalFlakeModule
          mkPerSystemOption
          mkPerSystemType
          mkTransposedPerSystemModule
          ;
      };
    };

  implementation =
    { ... }@module:
    {
      flake.lib = mkDefault (makeExtensible (final: library));
      flake.schemas = { inherit (local.config.flake.exportedSchemas) lib; };

      perSystem = { pkgs, ... }: {
        checks =
          let
            inherit (evalComponent { inherit (module) inputs; } nixology.core.lib) config;
          in
          {
            nixology-core-lib = pkgs.runCommandLocal "checks" {
              check_flake_lib_mkFlake = builtins.seq local.lib.flake.mkFlake "ok";
              check_flake_lib_metadataForFlakeInput = builtins.seq local.lib.flake.metadataForFlakeInput "ok";
              check_flake_lib_metadataForFlakeInput_self_flake-parts =
                (local.lib.flake.metadataForFlakeInput local.inputs.self local.inputs.flake-parts).pname;
            } "touch $out";
          };
      };

      touchup = {
        # hide attributes added to lib when using makeExtensible
        attr.lib.attr.__unfix__.enable = false;
      };
    };
in
{
  imports = [
    implementation
  ];

  # provide `flake.lib` attribute for core bootstrap import
  flake = {
    ${if config == null then "lib" else null} = library;
  };

  flake.components = {
    nixology.core.lib = {
      inherit implementation;

      dependencies = [
        nixology.core.perSystem
        nixology.core.schemas
        nixology.extra.touchup
      ];

      meta = {
        description = "Provide helper functions for nixology flakes and components.";
        shortDescription = "library functions for nixology";
      };
    };
  };
}
