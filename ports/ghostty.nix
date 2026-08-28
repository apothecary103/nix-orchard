{ lib, render }:

let
  # catppuccin/ghostty; selection is the overlay a fifth into the base.
  theme = p: {
    palette = lib.imap0 (i: colour: "${toString i}=${colour}") p.terminal.ansi;

    background = p.surface.background;
    foreground = p.surface.text;

    cursor-color = p.ui.cursor;
    cursor-text = if p.isLight then p.surface.background else p.surface.shadow;

    selection-background = render.mix {
      colour = p.surface.neutral5;
      over = p.surface.background;
    } 0.2;
    selection-foreground = p.surface.text;

    split-divider-color = p.surface.neutral0;
  };
in
{
  description = "ghostty";

  theme = { p, ... }: theme p;

  hjem = {
    when = { config, ... }: config.rum.programs.ghostty.enable;

    config =
      { data, name, ... }:
      {
        rum.programs.ghostty = {
          settings.theme = lib.mkDefault name;
          themes.${name} = data;
        };
      };
  };

  home = {
    when = { config, ... }: config.programs.ghostty.enable;

    config =
      { data, name, ... }:
      {
        programs.ghostty = {
          settings.theme = lib.mkDefault name;
          themes.${name} = data;
        };
      };
  };
}
