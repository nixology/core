{
  description = "A flake that provides systems variants";

  # this flake is only used for its inputs
  outputs = { ... }: { };

  inputs = {
    default.url = "github:nix-systems/default";
    default-darwin.url = "github:nix-systems/default-darwin";
    default-linux.url = "github:nix-systems/default-linux";
    aarch64-darwin.url = "github:nix-systems/aarch64-darwin";
    aarch64-linux.url = "github:nix-systems/aarch64-linux";
    x86_64-darwin.url = "github:nix-systems/x86_64-darwin";
    x86_64-linux.url = "github:nix-systems/x86_64-linux";
  };
}
