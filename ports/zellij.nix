{ lib, render }:

let
  # Every UI component takes a foreground, a background, and four emphases that
  # zellij picks between for key letters and highlighted words. Those are drawn
  # over the component's own background, so drop any hue that would land on it —
  # the accented ribbon is otherwise emphasised in its own background colour.
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

      # multiplayer_user_colors is left alone: zellij defaults it to ANSI slots,
      # which the terminal ports here already paint.
    };

  # The file is already named after the theme, but zellij still reads it as a
  # themes block and takes the name from the node inside.
  file = data: name: ''
    themes {
    ${render.toKdl "    " { ${name} = data; }}
    }
  '';
in
{
  description = "zellij";

  program = "zellij";

  # zellij bundles catppuccin, gruvbox and onedark in its own component format,
  # hand-authored per component rather than derived from twelve colours.
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
