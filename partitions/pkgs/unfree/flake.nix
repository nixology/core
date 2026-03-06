{
  description = "A flake for unfree nixpkgs";

  # this flake is only used for its inputs
  outputs = { ... }: { };

  inputs = {
    nixpkgs.url = "github:numtide/nixpkgs-unfree/nixpkgs-unstable";
    nixpkgs.inputs.nixpkgs.follows = "nixpkgs-unstable/nixpkgs";
    nixpkgs-unstable.url = "git+ssh://git@github.com/marksisson/std?dir=partitions/nixpkgs/unstable";
  };
}
