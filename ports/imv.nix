{ lib, render }:

let
  # catppuccin/imv, which takes bare RRGGBB; the overlay sits on crust.
  theme = p: {
    background = render.noHash p.surface.background;
    overlay_text_color = render.noHash p.surface.text;
    overlay_background_color = render.noHash p.surface.shadow;
  };
in
{
  description = "imv";

  theme = { p, ... }: theme p;

  hjem = {
    when = { config, ... }: config.rum.programs.imv.enable;
    config =
      { data, ... }:
      {
        rum.programs.imv.settings.options = lib.mapAttrsRecursive (_: lib.mkDefault) data;
      };
  };

  home = {
    when = { config, ... }: config.programs.imv.enable;
    config =
      { data, ... }:
      {
        programs.imv.settings.options = lib.mapAttrsRecursive (_: lib.mkDefault) data;
      };
  };
}
