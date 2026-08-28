{ lib, render }:

let
  # catppuccin/micro.
  theme =
    { p, transparent }:
    {
      default = if transparent then p.surface.text else "${p.surface.text},${p.surface.background}";
      comment = p.syntax.comment;
      selection = "${p.surface.text},${p.surface.neutral1}";
      hlsearch = p.hue.aqua;

      identifier = p.syntax.function;
      "identifier.class" = p.syntax.function;
      "identifier.var" = p.syntax.function;

      constant = p.syntax.constant;
      "constant.number" = p.syntax.number;
      "constant.string" = p.syntax.string;

      symbol = p.hue.pink;
      "symbol.brackets" = p.hue.cherry;
      "symbol.tag" = p.syntax.function;

      type = p.syntax.function;
      "type.keyword" = p.syntax.type;

      special = p.hue.pink;
      statement = p.syntax.keyword;
      preproc = p.hue.pink;

      underlined = p.hue.skye;
      error = "bold ${p.status.error}";
      todo = "bold ${p.status.warning}";

      "diff-added" = p.status.diffAdded;
      "diff-modified" = p.status.diffChanged;
      "diff-deleted" = p.status.diffDeleted;

      "gutter-error" = p.status.error;
      "gutter-warning" = p.status.warning;

      scrollbar = p.surface.neutral5;
      statusline = "${p.surface.text},${p.surface.panel}";
      tabbar = "${p.surface.text},${p.surface.panel}";
      "indent-char" = p.surface.neutral1;
      "line-number" = p.surface.neutral1;
      "current-line-number" = p.ui.secondaryAccent;

      "cursor-line" = "${p.ui.cursorLine},${p.surface.text}";
      "color-column" = p.surface.neutral0;
      "type.extended" = "default";
    };

  emit =
    data:
    lib.concatStringsSep "\n" (
      lib.mapAttrsToList (group: value: ''color-link ${group} "${value}"'') data
    )
    + "\n";
in
{
  description = "micro";

  program = "micro";

  # micro bundles gruvbox and one-dark as full colorschemes.
  integration = { };

  transparency = true;

  theme =
    { p, cfg, ... }:
    theme {
      inherit p;
      inherit (cfg) transparent;
    };

  hjem =
    {
      data,
      name,
      upstream,
      ...
    }:
    lib.mkIf (upstream == null) {
      xdg.config.files."micro/colorschemes/${name}.micro".text = emit data;
    };

  home =
    {
      data,
      name,
      upstream,
      ...
    }:
    {
      programs.micro.settings.colorscheme = lib.mkDefault name;

      xdg.configFile."micro/colorschemes/${name}.micro" = lib.mkIf (upstream == null) {
        text = emit data;
      };
    };
}
