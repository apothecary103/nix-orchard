{
  description = "Orchard: hand-crafted themes as home-manager, hjem and NixOS modules";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  inputs.home-manager = {
    url = "github:nix-community/home-manager";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    { nixpkgs, home-manager, ... }:
    let
      inherit (nixpkgs) lib;

      engine = import ./lib { inherit lib; };

      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];

      modulesFor = class: rec {
        orchard = engine.mkModule class;
        default = orchard;
      };
    in
    {
      lib = engine;

      # theme -> flavor -> the resolved palette, on that theme's default accent.
      palettes = lib.mapAttrs (
        name: theme:
        lib.genAttrs (engine.palette.flavorsOf theme) (
          flavor:
          engine.mkPalette name {
            inherit flavor;
            accent = theme.defaultAccent;
          }
        )
      ) engine.themes;

      hjemModules = modulesFor "hjem";
      homeModules = modulesFor "home";
      nixosModules = modulesFor "nixos";

      checks = lib.genAttrs systems (
        system:
        import ./tests {
          inherit lib engine;
          homeManager = home-manager;
          pkgs = nixpkgs.legacyPackages.${system};
        }
      );

      formatter = lib.genAttrs systems (system: nixpkgs.legacyPackages.${system}.nixfmt-tree);
    };
}
