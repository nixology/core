{
  description = "A flake for unfree nixpkgs";

  # this flake is only used for its inputs
  outputs = { ... }: { };

  inputs = {
    nixpkgs.url = "path:./nixpkgs";
  };
}
