{ lib, ... }:

let
  theme =
    p:
    let
      slots = lib.listToAttrs (
        lib.imap0 (i: colour: lib.nameValuePair "color${toString i}" colour) p.terminal.ansi
      );
    in
    {
      foreground = p.surface.text;
      background = p.surface.background;

      selection_foreground = p.surface.text;
      selection_background = p.ui.selection;

      cursor = p.ui.cursor;
      cursor_text_color = p.surface.background;

      url_color = p.hue.blue;

      active_border_color = p.ui.accent;
      inactive_border_color = p.surface.neutral1;
      bell_border_color = p.status.warning;

      visual_bell_color = p.status.warning;

      active_tab_foreground = p.surface.background;
      active_tab_background = p.ui.accent;
      inactive_tab_foreground = p.surface.textDim;
      inactive_tab_background = p.surface.neutral0;
      tab_bar_background = p.surface.panel;

      mark1_foreground = p.surface.background;
      mark1_background = p.ui.match;
      mark2_foreground = p.surface.background;
      mark2_background = p.hue.purple;
      mark3_foreground = p.surface.background;
      mark3_background = p.hue.aqua;
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
