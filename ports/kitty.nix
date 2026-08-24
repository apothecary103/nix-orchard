{ lib, ... }:

let
  theme =
    p:
    let
      slots = lib.listToAttrs (
        lib.imap0 (i: colour: lib.nameValuePair "color${toString i}" colour) p.ansi
      );
    in
    {
      foreground = p.text;
      background = p.base;

      selection_foreground = p.text;
      selection_background = p.selection;

      cursor = p.cursor;
      cursor_text_color = p.base;

      url_color = p.blue;

      active_border_color = p.accent;
      inactive_border_color = p.surface1;
      bell_border_color = p.warning;

      visual_bell_color = p.warning;

      active_tab_foreground = p.base;
      active_tab_background = p.accent;
      inactive_tab_foreground = p.subtext0;
      inactive_tab_background = p.surface0;
      tab_bar_background = p.mantle;

      mark1_foreground = p.base;
      mark1_background = p.match;
      mark2_foreground = p.base;
      mark2_background = p.purple;
      mark3_foreground = p.base;
      mark3_background = p.aqua;
    }
    // slots;
in
{
  description = "kitty";

  theme = { p, ... }: theme p;

  hjem = {
    when = { config, ... }: config.rum.programs.kitty.enable;

    config =
      { data, ... }:
      {
        rum.programs.kitty.settings = lib.mapAttrs (_: lib.mkDefault) data;
      };
  };

  home = {
    when = { config, ... }: config.programs.kitty.enable;

    config =
      { data, ... }:
      {
        programs.kitty.settings = lib.mapAttrs (_: lib.mkDefault) data;
      };
  };
}
