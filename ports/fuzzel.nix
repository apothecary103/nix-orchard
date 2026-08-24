{ render, ... }:

let
  # catppuccin/fuzzel. Everything is opaque except the background, which sits at
  # dd so the launcher reads as a panel rather than a window.
  theme =
    p:
    let
      opaque = colour: "${render.noHash colour}ff";
    in
    {
      background = "${render.noHash p.base}dd";
      text = opaque p.text;
      prompt = opaque p.subtext1;
      placeholder = opaque p.overlay1;
      input = opaque p.text;
      match = opaque p.accent;
      selection = opaque p.surface2;
      selection-text = opaque p.text;
      selection-match = opaque p.accent;
      counter = opaque p.overlay1;
      border = opaque p.accent;
    };
in
{
  description = "fuzzel";

  theme = { p, ... }: theme p;

  hjem = {
    when = { config, ... }: config.rum.programs.fuzzel.enable;
    config = { data, ... }: { rum.programs.fuzzel.settings.colors = data; };
  };

  home = {
    when = { config, ... }: config.programs.fuzzel.enable;
    config = { data, ... }: { programs.fuzzel.settings.colors = data; };
  };
}
