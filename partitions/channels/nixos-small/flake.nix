{
  description = "A flake for small nixos nixpkgs from channels";

  # this flake is only used for its inputs
  outputs = { ... }: { };

  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixos-25.11-small/nixexprs.tar.xz";
  };
}
