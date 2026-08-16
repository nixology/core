{
  config ? null,
  lib ? local.inputs.nixpkgs.lib,
  ...
}@local:
let
  inherit (local.inputs.self.components) nixology;

  inherit (lib)
    extend
    filter
    getAttrFromPath
    makeExtensible
    mkDefault
    optional
    optionals
    ;

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
        lib = extend (_final: _prev: library);
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

      implementationFrom = component: component.implementation;

      implementationsFrom = map implementationFrom;

      modulesIn =
        directory:
        if pathIsDirectory directory then
          filter (path: hasSuffix ".nix" path) (listFilesRecursive directory)
        else
          [ ];

      evalComponent = args: component: evalFlakeModule args component.implementation;

      mkComponent =
        {
          name,
          modules ? { },
          dependencies ? [ ],
          dogfoodPartition ? null,
          domain ? null,
          subdomain ? null,
          meta ? { },
        }:
        let
          componentRegistrationModule =
            { config, ... }:
            let
              inherit (config) flakeref;

              componentName = basename name;

              parsedFlakeref =
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

              resolvedDomain =
                if domain != null then
                  domain
                else if parsedFlakeref != null then
                  parsedFlakeref.owner
                else
                  abort "Unable to determine component domain.";

              resolvedSubdomain =
                if subdomain != null then
                  subdomain
                else if parsedFlakeref != null then
                  basename parsedFlakeref.repo
                else
                  abort "Unable to determine component subdomain.";

              flakeModule = modules.flake or null;

              classModules = removeAttrs modules [ "flake" ];

              modulesModule =
                if builtins.attrNames classModules == [ ] then
                  null
                else
                  {
                    flake.modules = builtins.mapAttrs (class: module: {
                      ${componentName} = {
                        key = "${flakeref}#modules.${class}.${componentName}";
                        imports = [ module ];
                      };
                    }) classModules;
                  };

              dogfoodFlakeModule =
                assert dogfoodPartition == null || builtins.isString dogfoodPartition;
                if flakeModule == null then
                  null
                else if dogfoodPartition == null then
                  flakeModule
                else
                  { partitions.${dogfoodPartition}.module = flakeModule; };

              dogfoodModule = {
                imports =
                  optional (dogfoodFlakeModule != null) dogfoodFlakeModule
                  ++ optional (modulesModule != null) modulesModule;
              };

              componentModule = {
                imports =
                  optional (flakeModule != null) flakeModule
                  ++ optional (modulesModule != null) modulesModule;
              };

              resolvedDependencies =
                let
                  coreFlakeref = (import "${local.inputs.self}/modules/flakeref.nix").flakeref;
                in
                dependencies
                ++ lib.optionals (flakeref != coreFlakeref) [
                  nixology.core.components
                  nixology.core.modules
                ];
            in
            {
              imports = [ dogfoodModule ];

              flake.components.${resolvedDomain}.${resolvedSubdomain}.${componentName} = {
                module = componentModule;
                dependencies = resolvedDependencies;
                inherit meta;
              };
            };
        in
        {
          imports = [ componentRegistrationModule ];
        };

      mkFlake =
        args: module:
        flake-parts-lib.mkFlake args {
          imports = [ module ] ++ optionals (config != null) [ nixology.core.default.implementation ];
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
          implementationFrom
          implementationsFrom
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

  module = {
    flake.lib = mkDefault (makeExtensible (_final: library));
    flake.schemas = { inherit (local.config.flake.exportedSchemas) lib; };

    perSystem = { pkgs, ... }: {
      checks = {
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
    module
  ];

  # provide `flake.lib` attribute for core bootstrap import
  flake = {
    ${if config == null then "lib" else null} = library;
  };

  flake.components = {
    nixology.core.lib = {
      inherit module;

      dependencies = [
        nixology.core.perSystem
        nixology.extra.touchup
      ];

      meta = {
        description = "Provide helper functions for nixology flakes and components.";
        shortDescription = "library functions for nixology";
      };
    };
  };
}
