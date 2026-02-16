{
  inputs,
  ...
}:
let
  default =
    let
      partition = "default";
    in
    {
      imports = [ inputs.flake-parts.flakeModules.partitions ];
      partitions.${partition} = {
        extraInputsFlake = ../partitions/${partition};
        module =
          { inputs, lib, ... }:
          {
            # default systems
            systems = lib.mkDefault (import inputs.systems);

            # default pkgs
            perSystem =
              { lib, system, ... }:
              {
                _module.args.pkgs = lib.mkDefault (
                  builtins.seq inputs.nixpkgs inputs.nixpkgs.legacyPackages.${system}
                );
              };
          };
      };
    };

  module = default;
in
module
