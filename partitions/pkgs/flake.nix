{
  description = "A flake for nixpkgs variants";

  # this flake is only used for its inputs
  outputs = { ... }: { };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-unfree.url = "github:numtide/nixpkgs-unfree/nixpkgs-unstable";
    nixpkgs-unfree.inputs.nixpkgs.follows = "nixpkgs-unstable";
  };
}
