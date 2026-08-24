{ ... }:

let
  # catppuccin/tofi is four lines; the rest below are tofi's own defaults spelled
  # out so the launcher does not fall back to its built-in blue.
  theme = p: {
    text-color = p.text;
    prompt-color = p.red;
    selection-color = p.warning;
    background-color = p.base;

    placeholder-color = p.overlay1;
    input-color = p.text;
    default-result-color = p.subtext1;
    selection-match-color = p.match;
    border-color = p.accent;
    outline-color = p.crust;
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
