{ render, ... }:

let
  # Colours only: every field left out keeps rmpc's own default, so a layout or
  # header defined elsewhere survives.
  theme =
    p:
    let
      bold = attrs: attrs // { modifiers = "Bold"; };
    in
    {
      text_color = p.surface.text;
      background_color = p.surface.background;
      header_background_color = p.surface.panel;
      modal_background_color = p.surface.panel;

      borders_style.fg = p.surface.neutral2;
      highlight_border_style.fg = p.ui.accent;

      tab_bar = {
        active_style = bold {
          fg = p.surface.background;
          bg = p.ui.accent;
        };
        inactive_style = {
          fg = p.surface.textDim;
          bg = p.surface.panel;
        };
      };

      highlighted_item_style = bold { fg = p.ui.accent; };
      current_item_style = bold {
        fg = p.surface.background;
        bg = p.ui.accent;
      };

      progress_bar = {
        track_style.fg = p.surface.neutral1;
        elapsed_style.fg = p.ui.accent;
        thumb_style.fg = p.ui.accent;
      };

      scrollbar = {
        track_style.fg = p.surface.neutral1;
        ends_style.fg = p.surface.neutral1;
        thumb_style.fg = p.ui.accent;
      };
    };

in
{
  # Only the theme file: rmpc takes config.ron as one opaque blob, so selecting
  # the theme stays the caller's job.
  description = "rmpc";

  program = "rmpc";

  theme = { p, ... }: theme p;

  hjem =
    { data, name, ... }:
    {
      xdg.config.files."rmpc/themes/${name}.ron".text = render.toRon "" data + "\n";
    };

  home =
    { data, name, ... }:
    {
      xdg.configFile."rmpc/themes/${name}.ron".text = render.toRon "" data + "\n";
    };
}
