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
      background = "${render.noHash p.surface.background}dd";
      text = opaque p.surface.text;
      prompt = opaque p.surface.textMuted;
      placeholder = opaque p.surface.neutral4;
      input = opaque p.surface.text;
      match = opaque p.ui.accent;
      selection = opaque p.surface.neutral2;
      selection-text = opaque p.surface.text;
      selection-match = opaque p.ui.accent;
      counter = opaque p.surface.neutral4;
      border = opaque p.ui.accent;
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
