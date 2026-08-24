{ render, ... }:

let
  # catppuccin/zathura. The two highlight colours are translucent so the text
  # under a search hit stays readable, which a solid fill destroys.
  theme =
    p:
    let
      rgba =
        colour: alpha:
        let
          channels = render.channels colour;
        in
        "rgba(${builtins.concatStringsSep "," (map toString channels)},${alpha})";

      rgb = colour: rgba colour "1";
    in
    {
      default-fg = rgb p.text;
      default-bg = rgb p.base;

      completion-bg = rgb p.surface0;
      completion-fg = rgb p.text;
      completion-highlight-bg = rgb p.accent;
      completion-highlight-fg = rgb p.base;
      completion-group-bg = rgb p.mantle;
      completion-group-fg = rgb p.text;

      statusbar-fg = rgb p.text;
      statusbar-bg = rgb p.crust;
      inputbar-fg = rgb p.text;
      inputbar-bg = rgb p.base;

      notification-bg = rgb p.base;
      notification-fg = rgb p.text;
      notification-error-bg = rgb p.base;
      notification-error-fg = rgb p.error;
      notification-warning-bg = rgb p.base;
      notification-warning-fg = rgb p.warning;

      recolor = true;
      recolor-lightcolor = rgb p.base;
      recolor-darkcolor = rgb p.text;

      index-fg = rgb p.text;
      index-bg = rgb p.base;
      index-active-fg = rgb p.text;
      index-active-bg = rgb p.surface0;

      render-loading-bg = rgb p.base;
      render-loading-fg = rgb p.text;

      highlight-color = rgba p.overlay2 "0.3";
      highlight-fg = rgb p.text;
      highlight-active-color = rgba p.accent "0.3";
    };
in
{
  # No hjem binding: zathura reads a single zathurarc, so a theme file of its
  # own would clobber the user's.
  description = "zathura";

  theme = { p, ... }: theme p;

  home = {
    when = { config, ... }: config.programs.zathura.enable;
    config = { data, ... }: { programs.zathura.options = data; };
  };
}
