{ lib, render }:

let
  # catppuccin/micro. Identifiers, types and tags all sit on blue, constants on
  # the constant hue, and the two symbol groups split between pink and the soft
  # warm tint.
  theme =
    { p, transparent }:
    {
      default = if transparent then p.text else "${p.text},${p.base}";
      comment = p.comment;
      selection = "${p.text},${p.surface1}";
      hlsearch = p.aqua;

      identifier = p.func;
      "identifier.class" = p.func;
      "identifier.var" = p.func;

      constant = p.constant;
      "constant.number" = p.number;
      "constant.string" = p.string;

      symbol = p.pink;
      "symbol.brackets" = p.cherry;
      "symbol.tag" = p.func;

      type = p.func;
      "type.keyword" = p.type;

      special = p.pink;
      statement = p.keyword;
      preproc = p.pink;

      underlined = p.skye;
      error = "bold ${p.error}";
      todo = "bold ${p.warning}";

      "diff-added" = p.add;
      "diff-modified" = p.change;
      "diff-deleted" = p.delete;

      "gutter-error" = p.error;
      "gutter-warning" = p.warning;

      scrollbar = p.overlay2;
      statusline = "${p.text},${p.mantle}";
      tabbar = "${p.text},${p.mantle}";
      "indent-char" = p.surface1;
      "line-number" = p.surface1;
      "current-line-number" = p.lavender;

      "cursor-line" = "${p.cursorline},${p.text}";
      "color-column" = p.surface0;
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
