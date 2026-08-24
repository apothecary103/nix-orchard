{ lib, ... }:

let
  theme = p: {
    colors = {
      foreground = p.text;
      background = p.base;

      cursor_bg = p.cursor;
      cursor_fg = p.base;
      cursor_border = p.cursor;

      selection_fg = p.text;
      selection_bg = p.selection;

      scrollbar_thumb = p.surface2;
      split = p.surface1;

      ansi = lib.sublist 0 8 p.ansi;
      brights = lib.sublist 8 8 p.ansi;

      compose_cursor = p.match;

      tab_bar = {
        background = p.crust;
        inactive_tab_edge = p.surface0;

        active_tab = {
          bg_color = p.base;
          fg_color = p.text;
        };
        inactive_tab = {
          bg_color = p.mantle;
          fg_color = p.subtext0;
        };
        inactive_tab_hover = {
          bg_color = p.surface0;
          fg_color = p.text;
        };
        new_tab = {
          bg_color = p.mantle;
          fg_color = p.subtext0;
        };
        new_tab_hover = {
          bg_color = p.surface0;
          fg_color = p.text;
        };
      };
    };

    metadata = {
      name = p.name;
      aliases = [ ];
    };
  };

in
{
  # wezterm loads every scheme it finds under `color_schemes_dirs`; the config
  # still has to name one, which stays the caller's job.
  description = "wezterm";

  program = "wezterm";

  theme = { p, name, ... }: theme (p // { inherit name; });

  hjem =
    {
      pkgs,
      data,
      name,
      ...
    }:
    {
      xdg.config.files."wezterm/colors/${name}.toml".source =
        (pkgs.formats.toml { }).generate "${name}.toml"
          data;
    };

  home =
    {
      pkgs,
      data,
      name,
      ...
    }:
    {
      xdg.configFile."wezterm/colors/${name}.toml".source =
        (pkgs.formats.toml { }).generate "${name}.toml"
          data;
    };
}
