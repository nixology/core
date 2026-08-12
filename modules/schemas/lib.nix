{
  config,
  inputs,
  lib,
  ...
}:
let
  inherit (config.partitions.schemas.extraInputs) flake-schemas;
  inherit (flake-schemas.lib) mkChildren;

  flake = {
    flake.exportedSchemas = {
      lib = {
        version = 1;

        doc = ''
          The lib flake output provides a collection of functions.
        '';

        inventory =
          let
            recurse =
              library:
              mkChildren (
                builtins.mapAttrs (
                  name: value:
                  if builtins.isAttrs value then
                    recurse value
                  else if builtins.isFunction value then
                    {
                      what = "library function";
                      # Make `nix flake check` enforce our naming convention.
                      evalChecks.camelCase = builtins.match "^[a-z][a-zA-Z]*$" name == [ ];
                    }
                  else
                    {
                      what = "library value";
                    }
                ) library
              );
          in
          recurse;
      };
    };
  };
in
lib.mkComponent {
  name = lib.basename __curPos.file;
  subdomain = "schemas";

  modules = { inherit flake; };

  dependencies = with inputs.self.components; [ nixology.core.exportedSchemas ];

  meta = {
    description = "Exported schemas for the lib flake output.";
    shortDescription = "exported schemas for the lib flake output";
  };
}
