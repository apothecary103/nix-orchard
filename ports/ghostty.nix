{ lib, render }:

let
  # catppuccin/ghostty. The selection background is the overlay a fifth of the
  # way into the base; everything else is a straight palette entry.
  theme = p: {
    palette = lib.imap0 (i: colour: "${toString i}=${colour}") p.ansi;

    background = p.base;
    foreground = p.text;

    cursor-color = p.cursor;
    cursor-text = if p.isLight then p.base else p.crust;

    selection-background = render.mix {
      colour = p.overlay2;
      over = p.base;
    } 0.2;
    selection-foreground = p.text;

    split-divider-color = p.surface0;
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
