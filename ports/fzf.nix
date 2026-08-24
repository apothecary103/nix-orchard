{ lib, ... }:

let
  # catppuccin/fzf, which is deliberately small: the prompt and info share one
  # hue, the highlights another, and the background steps come from the palette
  # rather than being left to the terminal.
  theme =
    { p, transparent }:
    {
      "bg+" = if transparent then "-1" else p.surface0;
      bg = if transparent then "-1" else p.base;
      spinner = p.cherry;
      hl = p.red;
      fg = p.text;
      header = p.red;
      info = p.keyword;
      pointer = p.cherry;
      marker = p.lavender;
      "fg+" = p.text;
      prompt = p.keyword;
      "hl+" = p.red;
      "selected-bg" = p.surface1;
      border = p.overlay0;
      label = p.text;
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
      environment.sessionVariables.FZF_DEFAULT_OPTS_FILE = "${pkgs.writeText "${name}-fzf.rc" ''
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
