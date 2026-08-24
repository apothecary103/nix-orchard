{ lib, ... }:

let
  # catppuccin/zsh-syntax-highlighting, which is greener than most ports: every
  # runnable word is the string hue, options are orange, and only the separators
  # and unclosed quotes go red.
  theme =
    p:
    let
      fg = colour: "fg=${colour}";
    in
    {
      comment = fg p.surface2;

      alias = fg p.ok;
      suffix-alias = fg p.ok;
      global-alias = fg p.ok;
      function = fg p.ok;
      command = fg p.ok;
      precommand = "${fg p.ok},italic";
      builtin = fg p.ok;
      reserved-word = fg p.ok;
      hashed-command = fg p.ok;

      autodirectory = "${fg p.orange},italic";
      single-hyphen-option = fg p.orange;
      double-hyphen-option = fg p.orange;

      back-quoted-argument = fg p.keyword;
      history-expansion = fg p.keyword;

      commandseparator = fg p.error;
      command-substitution-delimiter = fg p.text;
      command-substitution-delimiter-unquoted = fg p.text;
      process-substitution-delimiter = fg p.text;
      back-quoted-argument-delimiter = fg p.error;
      back-double-quoted-argument = fg p.error;
      back-dollar-quoted-argument = fg p.error;

      command-substitution-quoted = fg p.warning;
      command-substitution-delimiter-quoted = fg p.warning;
      single-quoted-argument = fg p.warning;
      single-quoted-argument-unclosed = fg p.maroon;
      double-quoted-argument = fg p.warning;
      double-quoted-argument-unclosed = fg p.maroon;
      rc-quote = fg p.warning;
      back-quoted-argument-unclosed = fg p.maroon;

      dollar-quoted-argument = fg p.warning;
      dollar-double-quoted-argument = fg p.escape;

      path = "${fg p.text},underline";
      path_pathseparator = "${fg p.error},underline";
      path_prefix = "${fg p.text},underline";
      path_prefix_pathseparator = "${fg p.error},underline";

      globbing = fg p.text;
      redirection = fg p.text;
      arg0 = fg p.text;
      assign = fg p.text;
      named-fd = fg p.text;
      numeric-fd = fg p.text;
      default = fg p.text;
      cursor = fg p.text;

      unknown-token = fg p.error;
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
