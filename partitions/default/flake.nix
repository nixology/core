{
  description = "private inputs for setting defaults.";

  # this flake is only used for its inputs
  outputs = { ... }: { };

  inputs = {
    # used for locking and following dependencies; do not access from parent flake
    main.url = "path:../..";

    # defaults
    pkgs = {
      url = "git+ssh://git@github.com/marksisson/pkgs";
      inputs.nixology.follows = "main";
    };

    systems.url = "github:nix-systems/default";
    systems-darwin.url = "github:nix-systems/default-darwin";
    systems-linux.url = "github:nix-systems/default-darwin";
  };
}
