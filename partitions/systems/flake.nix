{
  description = "A flake that provides systems variants";

  # this flake is only used for its inputs
  outputs = { ... }: { };

  inputs = {
    systems.url = "github:nix-systems/default";
    systems-darwin.url = "github:nix-systems/default-darwin";
    systems-linux.url = "github:nix-systems/default-linux";
  };
}
