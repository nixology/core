{
  description = "A flake for nixpkgs variants";

  # this flake is only used for its inputs
  outputs = { ... }: { };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-25.11-darwin";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-unfree.url = "github:numtide/nixpkgs-unfree/nixpkgs-unstable";
    nixpkgs-unfree.inputs.nixpkgs.follows = "nixpkgs-unstable";
  };
}
