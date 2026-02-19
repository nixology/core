{
  description = "A flake that provides systems variants";

  # this flake is only used for its inputs
  outputs = { ... }: { };

  inputs = {
    default.url = "github:nix-systems/default";
    default-darwin.url = "github:nix-systems/default-darwin";
    default-linux.url = "github:nix-systems/default-linux";
  };
}
