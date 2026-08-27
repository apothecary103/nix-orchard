{ lib, ... }:

let
  # catppuccin/starship ships a palette and three styled modules; the palette is
  # the contract, so the whole vocabulary goes in and the modules below only
  # ever name a role.
  theme = p: name: {
    palette = lib.mkDefault name;

    palettes.${name} = p.named;

    character = {
      success_symbol = lib.mkDefault "[❯](ok)";
      error_symbol = lib.mkDefault "[❯](error)";
      vimcmd_symbol = lib.mkDefault "[❮](subtext1)";
    };

    git_branch.style = lib.mkDefault "bold keyword";
    directory.style = lib.mkDefault "bold secondaryAccent";
  };
in
{
  description = "starship";

  theme = { p, name, ... }: theme p name;

  hjem = {
    when = { config, ... }: config.rum.programs.starship.enable;
    config = { data, ... }: { rum.programs.starship.settings = data; };
  };

  home = {
    when = { config, ... }: config.programs.starship.enable;
    config = { data, ... }: { programs.starship.settings = data; };
  };
}
