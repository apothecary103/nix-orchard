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
        p.accent
        p.keyword
        p.string
        p.type
        p.info
        p.match
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
      text_unselected = style p.text p.mantle;
      text_selected = style p.text p.selection;

      ribbon_unselected = style p.text p.surface1;
      ribbon_selected = style p.base p.accent;

      table_title = style p.title p.mantle;
      table_cell_unselected = style p.text p.mantle;
      table_cell_selected = style p.text p.selection;

      list_unselected = style p.text p.mantle;
      list_selected = style p.text p.selection;

      frame_unselected = style p.surface1 p.base;
      frame_selected = style p.accent p.base;
      frame_highlight = style p.match p.base;

      exit_code_success = style p.ok p.mantle;
      exit_code_error = style p.error p.mantle;

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
  upstream = true;

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
    lib.mkIf (upstream == null) {
      xdg.configFile."zellij/themes/${name}.kdl".text = file data name;
    };
}
