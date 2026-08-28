{ lib, ... }:

let
  theme = p: {
    colors = {
      foreground = p.surface.text;
      background = p.surface.background;

      cursor_bg = p.ui.cursor;
      cursor_fg = p.surface.background;
      cursor_border = p.ui.cursor;

      selection_fg = p.surface.text;
      selection_bg = p.ui.selection;

      scrollbar_thumb = p.surface.neutral2;
      split = p.surface.neutral1;

      ansi = lib.sublist 0 8 p.terminal.ansi;
      brights = lib.sublist 8 8 p.terminal.ansi;

      compose_cursor = p.ui.match;

      tab_bar = {
        background = p.surface.shadow;
        inactive_tab_edge = p.surface.neutral0;

        active_tab = {
          bg_color = p.surface.background;
          fg_color = p.surface.text;
        };
        inactive_tab = {
          bg_color = p.surface.panel;
          fg_color = p.surface.textDim;
        };
        inactive_tab_hover = {
          bg_color = p.surface.neutral0;
          fg_color = p.surface.text;
        };
        new_tab = {
          bg_color = p.surface.panel;
          fg_color = p.surface.textDim;
        };
        new_tab_hover = {
          bg_color = p.surface.neutral0;
          fg_color = p.surface.text;
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
  # wezterm loads every scheme it finds, but naming one is the caller's job.
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
      programs.wezterm.settings.color_scheme = lib.mkDefault name;

      xdg.configFile."wezterm/colors/${name}.toml".source =
        (pkgs.formats.toml { }).generate "${name}.toml"
          data;
    };
}
