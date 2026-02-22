{
  description = "A flake for nixpkgs variants from channels";

  # this flake is only used for its inputs
  outputs = { ... }: { };

  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixos-25.11/nixexprs.tar.xz";
    nixpkgs-darwin.url = "https://channels.nixos.org/nixpkgs-25.11-darwin/nixexprs.tar.xz";
    nixpkgs-unstable.url = "https://channels.nixos.org/nixpkgs-unstable/nixexprs.tar.xz";
    nixpkgs-unfree.url = "github:numtide/nixpkgs-unfree/nixpkgs-unstable";
    nixpkgs-unfree.inputs.nixpkgs.follows = "nixpkgs-unstable";
  };
}
