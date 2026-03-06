{ config, lib, ... }:
let
  variants = [ "default" "default-darwin" "default-linux" "aarch64-darwin" "aarch64-linux" "x86_64-darwin" "x86_64-linux" ];

  inputs = config.partitions.systems.extraInputs;

  systems = map
    (variant:
      let
        module = {
          systems =
            if variant == "default"
            then lib.mkDefault (import inputs."${variant}")
            # n.b. don't want merge semantics here; exclusively want specific systems variant, so mkForce
            else lib.mkForce (import inputs."${variant}");
        };
      in
      {
        inherit variant;
        component = {
          inherit module;
        };
      }
    )
    variants;
in
builtins.foldl' lib.recursiveUpdate { } (map
  (systems':
  { flake.components.nixology.systems.${systems'.variant} = systems'.component; }
  )
  systems)
