{ lib, ... }:

let
  # catppuccin/tmux is a plugin that only exports `@thm_*` variables and leaves
  # the styling to it. Both halves are here: the variables, so a hand-written
  # status line can name colours the same way, and the styles, so tmux looks
  # themed without one.
  theme = p: {
    variables = {
      thm_bg = p.surface.background;
      thm_fg = p.surface.text;

      thm_red = p.hue.red;
      thm_orange = p.hue.orange;
      thm_yellow = p.hue.yellow;
      thm_lime = p.hue.lime;
      thm_green = p.hue.green;
      thm_aqua = p.hue.aqua;
      thm_skye = p.hue.skye;
      thm_snow = p.hue.snow;
      thm_blue = p.hue.blue;
      thm_purple = p.hue.purple;
      thm_pink = p.hue.pink;
      thm_cherry = p.hue.cherry;

      thm_accent = p.ui.accent;

      thm_subtext_1 = p.surface.textDim;
      thm_subtext_0 = p.surface.textMuted;
      thm_overlay_2 = p.surface.neutral5;
      thm_overlay_1 = p.surface.neutral4;
      thm_overlay_0 = p.surface.neutral3;
      thm_surface_2 = p.surface.neutral2;
      thm_surface_1 = p.surface.neutral1;
      thm_surface_0 = p.surface.neutral0;
      thm_mantle = p.surface.panel;
      thm_crust = p.surface.shadow;
    };

    # Styles only, no status-left/right content, so this composes with whatever
    # status line you already have. Later config wins.
    styles = {
      mode-style = "fg=${p.surface.background},bg=${p.ui.accent}";
      message-style = "fg=${p.surface.text},bg=${p.surface.neutral0}";
      message-command-style = "fg=${p.surface.text},bg=${p.surface.neutral0}";

      pane-border-style = "fg=${p.surface.neutral1}";
      pane-active-border-style = "fg=${p.ui.accent}";

      status-style = "fg=${p.surface.textDim},bg=${p.surface.panel}";
      status-left-style = "fg=${p.ui.accent},bg=${p.surface.panel}";
      status-right-style = "fg=${p.surface.textDim},bg=${p.surface.panel}";

      display-panes-active-colour = p.ui.accent;
      display-panes-colour = p.surface.neutral3;

      copy-mode-match-style = "fg=${p.surface.background},bg=${p.ui.search}";
      copy-mode-current-match-style = "fg=${p.surface.background},bg=${p.ui.match}";
      copy-mode-mark-style = "fg=${p.surface.background},bg=${p.ui.accent}";
    };

    windowStyles = {
      window-status-style = "fg=${p.surface.neutral4},bg=${p.surface.panel}";
      window-status-current-style = "fg=${p.ui.accent},bg=${p.surface.panel},bold";
      window-status-activity-style = "fg=${p.status.warning},bg=${p.surface.panel}";
      window-status-bell-style = "fg=${p.status.error},bg=${p.surface.panel},bold";
      clock-mode-colour = p.ui.accent;
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
