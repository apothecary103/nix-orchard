{ lib, ... }:

let
  # catppuccin/tmux is a plugin that only exports `@thm_*` variables and leaves
  # the styling to it. Both halves are here: the variables, so a hand-written
  # status line can name colours the same way, and the styles, so tmux looks
  # themed without one.
  theme = p: {
    variables = {
      thm_bg = p.base;
      thm_fg = p.text;

      thm_red = p.red;
      thm_orange = p.orange;
      thm_yellow = p.yellow;
      thm_lime = p.lime;
      thm_green = p.green;
      thm_aqua = p.aqua;
      thm_skye = p.skye;
      thm_snow = p.snow;
      thm_blue = p.blue;
      thm_purple = p.purple;
      thm_pink = p.pink;
      thm_cherry = p.cherry;

      thm_accent = p.accent;

      thm_subtext_1 = p.subtext0;
      thm_subtext_0 = p.subtext1;
      thm_overlay_2 = p.overlay2;
      thm_overlay_1 = p.overlay1;
      thm_overlay_0 = p.overlay0;
      thm_surface_2 = p.surface2;
      thm_surface_1 = p.surface1;
      thm_surface_0 = p.surface0;
      thm_mantle = p.mantle;
      thm_crust = p.crust;
    };

    # Styles only, no status-left/right content, so this composes with whatever
    # status line you already have. Later config wins.
    styles = {
      mode-style = "fg=${p.base},bg=${p.accent}";
      message-style = "fg=${p.text},bg=${p.surface0}";
      message-command-style = "fg=${p.text},bg=${p.surface0}";

      pane-border-style = "fg=${p.surface1}";
      pane-active-border-style = "fg=${p.accent}";

      status-style = "fg=${p.subtext0},bg=${p.mantle}";
      status-left-style = "fg=${p.accent},bg=${p.mantle}";
      status-right-style = "fg=${p.subtext0},bg=${p.mantle}";

      display-panes-active-colour = p.accent;
      display-panes-colour = p.overlay0;

      copy-mode-match-style = "fg=${p.base},bg=${p.search}";
      copy-mode-current-match-style = "fg=${p.base},bg=${p.match}";
      copy-mode-mark-style = "fg=${p.base},bg=${p.accent}";
    };

    windowStyles = {
      window-status-style = "fg=${p.overlay1},bg=${p.mantle}";
      window-status-current-style = "fg=${p.accent},bg=${p.mantle},bold";
      window-status-activity-style = "fg=${p.warning},bg=${p.mantle}";
      window-status-bell-style = "fg=${p.error},bg=${p.mantle},bold";
      clock-mode-colour = p.accent;
    };
  };

  emit =
    data:
    lib.concatStringsSep "\n" (
      lib.mapAttrsToList (key: value: ''set -ogq @${key} "${value}"'') data.variables
      ++ lib.mapAttrsToList (key: value: ''set -g ${key} "${value}"'') data.styles
      ++ lib.mapAttrsToList (key: value: ''setw -g ${key} "${value}"'') data.windowStyles
    )
    + "\n";
in
{
  description = "tmux";

  program = "tmux";

  theme = { p, ... }: theme p;

  options = {
    configFile = lib.mkOption {
      type = lib.types.str;
      readOnly = true;
      default = "tmux/orchard.conf";
      description = ''
        Path, relative to `$XDG_CONFIG_HOME`, of the file to `source-file` from
        {file}`tmux.conf`. Neither module tree has a tmux port to merge styles
        into, so the theme is loaded by hand. The name does not carry the theme,
        so switching one does not churn `tmux.conf`.
      '';
    };
  };

  hjem =
    { data, cfg, ... }:
    {
      xdg.config.files.${cfg.configFile}.text = emit data;
    };

  home =
    { data, cfg, ... }:
    {
      xdg.configFile.${cfg.configFile}.text = emit data;
    };
}
