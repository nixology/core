{
  description = "nixpkgs with the unfree bits enabled";

  inputs.nixpkgs.follows = "unstable/nixpkgs";
  inputs.unstable.url = "path:../../unstable";

  outputs =
    { nixpkgs, ... }:
    let
      eachSystem = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed;
    in
    nixpkgs
    // {
      legacyPackages = eachSystem (
        system:
        import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
          };
        }
      );
    };
}
