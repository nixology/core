{
  description = "private inputs for setting defaults.";

  # this flake is only used for its inputs
  outputs = { ... }: { };

  inputs = {
    # used for locking and following dependencies; do not access from parent flake
    main.url = "path:../..";

    # defaults
    nixpkgs.url = "github:nixos/nixpkgs";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-unfree.url = "github:numtide/nixpkgs-unfree/nixpkgs-unstable";
    nixpkgs-unfree.inputs.nixpkgs.follows = "nixpkgs-unstable";

    systems.url = "github:nix-systems/default";
    systems-darwin.url = "github:nix-systems/default-darwin";
    systems-linux.url = "github:nix-systems/default-darwin";
  };
}
