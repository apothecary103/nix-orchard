{ lib, ... }:

let
  # catppuccin/mako, which colours the border by urgency and nothing else.
  theme = p: {
    background-color = p.surface.background;
    text-color = p.surface.text;
    border-color = p.ui.accent;
    progress-color = "over ${p.surface.neutral0}";

    "urgency=high".border-color = p.hue.orange;
  };
in
{
  # No hjem binding: mako reads a single config, so a file would clobber it.
  description = "mako";

  theme = { p, ... }: theme p;

  home = {
    when = { config, ... }: config.services.mako.enable;
    config =
      { data, ... }:
      {
        services.mako.settings = lib.mapAttrsRecursive (_: lib.mkDefault) data;
      };
  };
}
