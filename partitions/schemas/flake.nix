{
  description = "A flake that provides flake schemas";

  # this flake is only used for its inputs
  outputs = { ... }: { };

  inputs = {
    flake-schemas.url = "github:DeterminateSystems/flake-schemas";
  };
}
