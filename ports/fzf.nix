{ lib, ... }:

let
  # catppuccin/fzf, which is deliberately small: the prompt and info share one
  # hue, the highlights another, and the background steps come from the palette
  # rather than being left to the terminal.
  theme =
    { p, transparent }:
    {
      "bg+" = if transparent then "-1" else p.surface.neutral0;
      bg = if transparent then "-1" else p.surface.background;
      spinner = p.hue.cherry;
      hl = p.hue.red;
      fg = p.surface.text;
      header = p.hue.red;
      info = p.syntax.keyword;
      pointer = p.hue.cherry;
      marker = p.ui.secondaryAccent;
      "fg+" = p.surface.text;
      prompt = p.syntax.keyword;
      "hl+" = p.hue.red;
      "selected-bg" = p.surface.neutral1;
      border = p.surface.neutral3;
      label = p.surface.text;
    };
in
{
  description = "fzf";

  program = "fzf";

  transparency = true;

  theme =
    { p, cfg, ... }:
    theme {
      inherit p;
      inherit (cfg) transparent;
    };

  # fzf has no config file of its own; --color is read from an opts file.
  hjem =
    {
      pkgs,
      data,
      name,
      ...
    }:
    let
      colours = lib.concatStringsSep "," (lib.mapAttrsToList (slot: colour: "${slot}:${colour}") data);
    in
    {
      environment.sessionVariables.FZF_DEFAULT_OPTS_FILE = lib.mkDefault "${pkgs.writeText "${name}-fzf.rc" ''
        --color=${colours}
      ''}";
    };

  home = {
    when = { config, ... }: config.programs.fzf.enable;

    config =
      { data, ... }:
      {
        programs.fzf.colors = lib.mapAttrs (_: lib.mkDefault) data;
      };
  };
}
