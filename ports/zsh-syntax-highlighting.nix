{ lib, ... }:

let
  # catppuccin/zsh-syntax-highlighting.
  theme =
    p:
    let
      fg = colour: "fg=${colour}";
    in
    {
      comment = fg p.surface.neutral2;

      alias = fg p.status.success;
      suffix-alias = fg p.status.success;
      global-alias = fg p.status.success;
      function = fg p.status.success;
      command = fg p.status.success;
      precommand = "${fg p.status.success},italic";
      builtin = fg p.status.success;
      reserved-word = fg p.status.success;
      hashed-command = fg p.status.success;

      autodirectory = "${fg p.hue.orange},italic";
      single-hyphen-option = fg p.hue.orange;
      double-hyphen-option = fg p.hue.orange;

      back-quoted-argument = fg p.syntax.keyword;
      history-expansion = fg p.syntax.keyword;

      commandseparator = fg p.status.error;
      command-substitution-delimiter = fg p.surface.text;
      command-substitution-delimiter-unquoted = fg p.surface.text;
      process-substitution-delimiter = fg p.surface.text;
      back-quoted-argument-delimiter = fg p.status.error;
      back-double-quoted-argument = fg p.status.error;
      back-dollar-quoted-argument = fg p.status.error;

      command-substitution-quoted = fg p.status.warning;
      command-substitution-delimiter-quoted = fg p.status.warning;
      single-quoted-argument = fg p.status.warning;
      single-quoted-argument-unclosed = fg p.status.errorMuted;
      double-quoted-argument = fg p.status.warning;
      double-quoted-argument-unclosed = fg p.status.errorMuted;
      rc-quote = fg p.status.warning;
      back-quoted-argument-unclosed = fg p.status.errorMuted;

      dollar-quoted-argument = fg p.status.warning;
      dollar-double-quoted-argument = fg p.syntax.escape;

      path = "${fg p.surface.text},underline";
      path_pathseparator = "${fg p.status.error},underline";
      path_prefix = "${fg p.surface.text},underline";
      path_prefix_pathseparator = "${fg p.status.error},underline";

      globbing = fg p.surface.text;
      redirection = fg p.surface.text;
      arg0 = fg p.surface.text;
      assign = fg p.surface.text;
      named-fd = fg p.surface.text;
      numeric-fd = fg p.surface.text;
      default = fg p.surface.text;
      cursor = fg p.surface.text;

      unknown-token = fg p.status.error;
      cursor-matchingbracket = "standout";
    };

  init =
    data:
    lib.concatStringsSep "\n" (
      lib.mapAttrsToList (key: value: "ZSH_HIGHLIGHT_STYLES[${key}]=${lib.escapeShellArg value}") data
    );
in
{
  description = "zsh-syntax-highlighting";

  theme = { p, ... }: theme p;

  hjem = {
    when = { config, ... }: config.rum.programs.zsh.enable;

    config =
      { data, ... }:
      {
        rum.programs.zsh.initConfig = lib.mkOrder 950 (init data);
      };
  };

  home = {
    when = { config, ... }: config.programs.zsh.syntaxHighlighting.enable;

    config =
      { data, ... }:
      {
        programs.zsh.initContent = lib.mkOrder 950 (init data);
      };
  };
}
