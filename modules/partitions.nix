{
  config,
  inputs,
  lib,
  ...
}:
let
  default =
    let
      partition = "default";
    in
    {
      imports = [ inputs.flake-parts.flakeModules.partitions ];
      partitions.${partition} =
        let
          inputs = config.partitions.default.extraInputs;
        in
        {
          extraInputsFlake = ../partitions/${partition};
          module = {
            # default systems
            systems = lib.mkDefault (import inputs.systems);

            # default pkgs
            imports = [ inputs.pkgs.components.nixology.pkgs.nixpkgs ];
          };
        };
    };

  module = default;
in
module
