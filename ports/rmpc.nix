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
      text_color = p.text;
      background_color = p.base;
      header_background_color = p.mantle;
      modal_background_color = p.mantle;

      borders_style.fg = p.surface2;
      highlight_border_style.fg = p.accent;

      tab_bar = {
        active_style = bold {
          fg = p.base;
          bg = p.accent;
        };
        inactive_style = {
          fg = p.subtext0;
          bg = p.mantle;
        };
      };

      highlighted_item_style = bold { fg = p.accent; };
      current_item_style = bold {
        fg = p.base;
        bg = p.accent;
      };

      progress_bar = {
        track_style.fg = p.surface1;
        elapsed_style.fg = p.accent;
        thumb_style.fg = p.accent;
      };

      scrollbar = {
        track_style.fg = p.surface1;
        ends_style.fg = p.surface1;
        thumb_style.fg = p.accent;
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
