{ ... }:

let
  # catppuccin/tofi is four lines; the rest below are tofi's own defaults spelled
  # out so the launcher does not fall back to its built-in blue.
  theme = p: {
    text-color = p.surface.text;
    prompt-color = p.hue.red;
    selection-color = p.status.warning;
    background-color = p.surface.background;

    placeholder-color = p.surface.neutral4;
    input-color = p.surface.text;
    default-result-color = p.surface.textMuted;
    selection-match-color = p.ui.match;
    border-color = p.ui.accent;
    outline-color = p.surface.shadow;
  };
in
{
  description = "tofi";

  theme = { p, ... }: theme p;

  hjem = {
    when = { config, ... }: config.rum.programs.tofi.enable;
    config = { data, ... }: { rum.programs.tofi.settings = data; };
  };

  home = {
    when = { config, ... }: config.programs.tofi.enable;
    config = { data, ... }: { programs.tofi.settings = data; };
  };
}
