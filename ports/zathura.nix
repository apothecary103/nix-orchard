{ lib, render }:

let
  # catppuccin/zathura; the highlights are translucent so hit text stays readable.
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
      default-fg = rgb p.surface.text;
      default-bg = rgb p.surface.background;

      completion-bg = rgb p.surface.neutral0;
      completion-fg = rgb p.surface.text;
      completion-highlight-bg = rgb p.ui.accent;
      completion-highlight-fg = rgb p.surface.background;
      completion-group-bg = rgb p.surface.panel;
      completion-group-fg = rgb p.surface.text;

      statusbar-fg = rgb p.surface.text;
      statusbar-bg = rgb p.surface.shadow;
      inputbar-fg = rgb p.surface.text;
      inputbar-bg = rgb p.surface.background;

      notification-bg = rgb p.surface.background;
      notification-fg = rgb p.surface.text;
      notification-error-bg = rgb p.surface.background;
      notification-error-fg = rgb p.status.error;
      notification-warning-bg = rgb p.surface.background;
      notification-warning-fg = rgb p.status.warning;

      recolor = true;
      recolor-lightcolor = rgb p.surface.background;
      recolor-darkcolor = rgb p.surface.text;

      index-fg = rgb p.surface.text;
      index-bg = rgb p.surface.background;
      index-active-fg = rgb p.surface.text;
      index-active-bg = rgb p.surface.neutral0;

      render-loading-bg = rgb p.surface.background;
      render-loading-fg = rgb p.surface.text;

      highlight-color = rgba p.surface.neutral5 "0.3";
      highlight-fg = rgb p.surface.text;
      highlight-active-color = rgba p.ui.accent "0.3";
    };
in
{
  # No hjem binding: zathura reads a single zathurarc, so a file would clobber it.
  description = "zathura";

  theme = { p, ... }: theme p;

  home = {
    when = { config, ... }: config.programs.zathura.enable;
    config =
      { data, ... }:
      {
        programs.zathura.options = lib.mapAttrsRecursive (_: lib.mkDefault) data;
      };
  };
}
