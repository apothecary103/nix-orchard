{ lib, ... }:

let
  # catppuccin/mako, which colours the border by urgency and leaves the rest of
  # the notification alone.
  theme = p: {
    background-color = p.surface.background;
    text-color = p.surface.text;
    border-color = p.ui.accent;
    progress-color = "over ${p.surface.neutral0}";

    "urgency=high".border-color = p.hue.orange;
  };
in
{
  # No hjem binding: mako reads a single `mako/config`, so a theme file of its
  # own would clobber the user's.
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
