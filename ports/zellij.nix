{ lib, render }:

let
  # Emphases are drawn over the component's background, so drop any hue matching it.
  theme =
    p:
    let
      hues = lib.unique [
        p.ui.accent
        p.syntax.keyword
        p.syntax.string
        p.syntax.type
        p.status.info
        p.ui.match
      ];

      style =
        base: background:
        {
          inherit base background;
        }
        // lib.listToAttrs (
          lib.imap0 (i: hue: lib.nameValuePair "emphasis_${toString i}" hue) (
            lib.take 4 (lib.filter (hue: hue != background) hues)
          )
        );
    in
    {
      text_unselected = style p.surface.text p.surface.panel;
      text_selected = style p.surface.text p.ui.selection;

      ribbon_unselected = style p.surface.text p.surface.neutral1;
      ribbon_selected = style p.surface.background p.ui.accent;

      table_title = style p.ui.title p.surface.panel;
      table_cell_unselected = style p.surface.text p.surface.panel;
      table_cell_selected = style p.surface.text p.ui.selection;

      list_unselected = style p.surface.text p.surface.panel;
      list_selected = style p.surface.text p.ui.selection;

      frame_unselected = style p.surface.neutral1 p.surface.background;
      frame_selected = style p.ui.accent p.surface.background;
      frame_highlight = style p.ui.match p.surface.background;

      exit_code_success = style p.status.success p.surface.panel;
      exit_code_error = style p.status.error p.surface.panel;

      # multiplayer_user_colors defaults to ANSI slots, which are already painted.
    };

  # zellij takes the theme name from the node inside, not from the file name.
  file = data: name: ''
    themes {
    ${render.toKdl "    " { ${name} = data; }}
    }
  '';
in
{
  description = "zellij";

  program = "zellij";

  # zellij bundles catppuccin, gruvbox and onedark in its own component format.
  integration = { };

  theme = { p, ... }: theme p;

  hjem =
    {
      data,
      name,
      upstream,
      ...
    }:
    lib.mkIf (upstream == null) {
      xdg.config.files."zellij/themes/${name}.kdl".text = file data name;
    };

  home =
    {
      data,
      name,
      upstream,
      ...
    }:
    {
      programs.zellij.settings.theme = lib.mkDefault name;

      xdg.configFile."zellij/themes/${name}.kdl" = lib.mkIf (upstream == null) {
        text = file data name;
      };
    };
}
