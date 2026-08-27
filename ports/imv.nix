{ render, ... }:

let
  # catppuccin/imv. imv takes bare RRGGBB, and the overlay sits on the crust so
  # it stays legible over a bright image.
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
    config = { data, ... }: { rum.programs.imv.settings.options = data; };
  };

  home = {
    when = { config, ... }: config.programs.imv.enable;
    config = { data, ... }: { programs.imv.settings.options = data; };
  };
}
