{ lib, ... }:

let
  # catppuccin/alacritty for everything around the grid; the sixteen slots
  # themselves come from the theme's own `ansi`, which is the mapping each
  # upstream project chose for its terminal.
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
          ] (lib.sublist offset 8 p.ansi)
        );
    in
    {
      primary = {
        background = p.base;
        foreground = p.text;
        dim_foreground = p.overlay1;
        bright_foreground = p.text;
      };

      cursor = {
        text = p.base;
        cursor = p.cursor;
      };
      vi_mode_cursor = {
        text = p.base;
        cursor = p.lavender;
      };

      search = {
        matches = {
          foreground = p.base;
          background = p.subtext0;
        };
        focused_match = {
          foreground = p.base;
          background = p.ok;
        };
      };

      footer_bar = {
        foreground = p.base;
        background = p.subtext0;
      };

      hints = {
        start = {
          foreground = p.base;
          background = p.warning;
        };
        end = {
          foreground = p.base;
          background = p.subtext0;
        };
      };

      selection = {
        text = p.base;
        background = p.cursor;
      };

      normal = slots 0;
      bright = slots 8;

      indexed_colors = [
        {
          index = 16;
          color = p.orange;
        }
        {
          index = 17;
          color = p.cherry;
        }
      ];
    };
in
{
  description = "alacritty";

  theme = { p, ... }: theme p;

  hjem = {
    when = { config, ... }: config.rum.programs.alacritty.enable;
    config = { data, ... }: { rum.programs.alacritty.settings.colors = data; };
  };

  home = {
    when = { config, ... }: config.programs.alacritty.enable;
    config = { data, ... }: { programs.alacritty.settings.colors = data; };
  };
}
