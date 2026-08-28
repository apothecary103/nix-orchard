{ lib, ... }:

let
  # catppuccin/alacritty, but the sixteen slots come from the theme's own ansi.
  theme =
    p:
    let
      slots =
        offset:
        lib.listToAttrs (
          lib.zipListsWith lib.nameValuePair [
            "black"
            "red"
            "green"
            "yellow"
            "blue"
            "magenta"
            "cyan"
            "white"
          ] (lib.sublist offset 8 p.terminal.ansi)
        );
    in
    {
      primary = {
        background = p.surface.background;
        foreground = p.surface.text;
        dim_foreground = p.surface.neutral4;
        bright_foreground = p.surface.text;
      };

      cursor = {
        text = p.surface.background;
        cursor = p.ui.cursor;
      };
      vi_mode_cursor = {
        text = p.surface.background;
        cursor = p.ui.secondaryAccent;
      };

      search = {
        matches = {
          foreground = p.surface.background;
          background = p.surface.textDim;
        };
        focused_match = {
          foreground = p.surface.background;
          background = p.status.success;
        };
      };

      footer_bar = {
        foreground = p.surface.background;
        background = p.surface.textDim;
      };

      hints = {
        start = {
          foreground = p.surface.background;
          background = p.status.warning;
        };
        end = {
          foreground = p.surface.background;
          background = p.surface.textDim;
        };
      };

      selection = {
        text = p.surface.background;
        background = p.ui.cursor;
      };

      normal = slots 0;
      bright = slots 8;

      indexed_colors = [
        {
          index = 16;
          color = p.hue.orange;
        }
        {
          index = 17;
          color = p.hue.cherry;
        }
      ];
    };
in
{
  description = "alacritty";

  theme = { p, ... }: theme p;

  hjem = {
    when = { config, ... }: config.rum.programs.alacritty.enable;
    config =
      { data, ... }:
      {
        rum.programs.alacritty.settings.colors = lib.mapAttrsRecursive (_: lib.mkDefault) data;
      };
  };

  home = {
    when = { config, ... }: config.programs.alacritty.enable;
    config =
      { data, ... }:
      {
        programs.alacritty.settings.colors = lib.mapAttrsRecursive (_: lib.mkDefault) data;
      };
  };
}
