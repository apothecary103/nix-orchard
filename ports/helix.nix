{ lib, render }:

let
  # catppuccin/helix, scope for scope. Where upstream names a hue the hue is
  # named here too, so a theme's own hue choices carry through; where it names a
  # surface or something semantic, the role is used instead.
  theme =
    { p, transparent }:
    let
      curl = colour: {
        underline = {
          color = colour;
          style = "curl";
        };
      };

      italic = fg: {
        inherit fg;
        modifiers = [ "italic" ];
      };

      over =
        colour: amount:
        render.mix {
          inherit colour;
          over = p.surface.background;
        } amount;

      # Upstream derives these rather than picking a palette step: the cursor
      # line is a fraction of surface0 over the background, and each secondary
      # cursor is its primary washed out to 70%.
      derived = {
        cursorline = if p.isLight then over p.surface.panel 0.7 else over p.surface.neutral0 0.64;
        secondary_cursor = over p.ui.cursor 0.7;
        secondary_cursor_normal = over p.ui.cursor 0.7;
        secondary_cursor_insert = over p.status.success 0.7;
        secondary_cursor_select = over p.status.info 0.7;
      };
    in
    {
      "attribute" = "annotation";

      "type" = "type";
      "type.builtin" = "keyword";
      "type.enum.variant" = "property";

      "constructor" = "func";

      "constant" = "constant";
      "constant.character" = "string";
      "constant.character.escape" = "escape";

      "string" = "string";
      "string.regexp" = "escape";
      "string.special" = "func";
      "string.special.symbol" = "constant";

      "comment" = italic "comment";

      "variable" = "variable";
      "variable.parameter" = italic "variable";
      "variable.builtin" = "constant";
      "variable.other.member" = "property";

      "label" = "special";

      "punctuation" = "punctuation";
      "punctuation.special" = "skye";

      "keyword" = "keyword";
      "keyword.control.conditional" = italic "keyword";

      "operator" = "operator";

      "function" = "func";
      "function.macro" = "macro";

      "tag" = "property";

      "namespace" = italic "module";

      "special" = "special";

      "markup.heading.1" = "rainbow0";
      "markup.heading.2" = "rainbow1";
      "markup.heading.3" = "rainbow2";
      "markup.heading.4" = "rainbow3";
      "markup.heading.5" = "rainbow4";
      "markup.heading.6" = "rainbow5";
      "markup.list" = "punctuation";
      "markup.list.unchecked" = "overlay2";
      "markup.list.checked" = "ok";
      "markup.bold".modifiers = [ "bold" ];
      "markup.italic".modifiers = [ "italic" ];
      "markup.strikethrough".modifiers = [ "crossed_out" ];
      "markup.link.url" = {
        fg = "info";
        modifiers = [
          "italic"
          "underlined"
        ];
      };
      "markup.link.text" = "module";
      "markup.link.label" = "special";
      "markup.raw" = "string";
      "markup.quote" = "comment";

      "diff.plus" = "add";
      "diff.minus" = "delete";
      "diff.delta" = "change";

      "ui.background" = {
        fg = "text";
        bg = if transparent then "none" else "base";
      };

      "ui.linenr".fg = "surface2";
      "ui.linenr.selected".fg = "overlay2";

      # Helix's convention throughout its own themes: the active bar carries the
      # theme's brightest chrome text and the inactive one a dimmer step, both on
      # the same surface, with the mode block reading as accent-on-background.
      "ui.statusline" = {
        fg = "statusFg";
        bg = "statusBg";
      };
      "ui.statusline.inactive" = {
        fg = "statusDim";
        bg = "statusBg";
      };
      "ui.statusline.normal" = {
        fg = "base";
        bg = "accent";
        modifiers = [ "bold" ];
      };
      "ui.statusline.insert" = {
        fg = "base";
        bg = "ok";
        modifiers = [ "bold" ];
      };
      "ui.statusline.select" = {
        fg = "base";
        bg = "info";
        modifiers = [ "bold" ];
      };

      "ui.popup" = {
        fg = "text";
        bg = "surface0";
      };
      "ui.window".fg = "crust";
      "ui.help" = {
        fg = "overlay2";
        bg = "surface0";
      };

      "ui.bufferline" = {
        fg = "subtext0";
        bg = "mantle";
      };
      "ui.bufferline.active" = {
        fg = "accent";
        bg = "base";
        underline = {
          color = "accent";
          style = "line";
        };
      };
      "ui.bufferline.background".bg = "crust";

      "ui.text" = "text";
      "ui.text.focus" = {
        fg = "text";
        bg = "surface0";
        modifiers = [ "bold" ];
      };
      "ui.text.inactive".fg = "overlay1";
      "ui.text.directory".fg = "info";

      "ui.virtual" = "overlay0";
      "ui.virtual.ruler".bg = "surface0";
      "ui.virtual.indent-guide" = "surface0";
      "ui.virtual.inlay-hint" = {
        fg = "surface1";
        bg = "mantle";
      };
      "ui.virtual.jump-label" = {
        fg = "match";
        modifiers = [ "bold" ];
      };

      "ui.selection".bg = "selection";

      "ui.cursor" = {
        fg = "base";
        bg = "secondary_cursor";
      };
      "ui.cursor.primary" = {
        fg = "base";
        bg = "cursor";
      };
      "ui.cursor.match" = {
        fg = "match";
        modifiers = [ "bold" ];
      };

      "ui.cursor.primary.normal" = {
        fg = "base";
        bg = "cursor";
      };
      "ui.cursor.primary.insert" = {
        fg = "base";
        bg = "ok";
      };
      "ui.cursor.primary.select" = {
        fg = "base";
        bg = "info";
      };

      "ui.cursor.normal" = {
        fg = "base";
        bg = "secondary_cursor_normal";
      };
      "ui.cursor.insert" = {
        fg = "base";
        bg = "secondary_cursor_insert";
      };
      "ui.cursor.select" = {
        fg = "base";
        bg = "secondary_cursor_select";
      };

      "ui.cursorline.primary".bg = "cursorline";

      "ui.highlight" = {
        bg = "surface1";
        modifiers = [ "bold" ];
      };

      "ui.menu" = {
        fg = "overlay2";
        bg = "surface0";
      };
      "ui.menu.selected" = {
        fg = "text";
        bg = "surface1";
        modifiers = [ "bold" ];
      };

      "diagnostic.error" = curl "error";
      "diagnostic.warning" = curl "warning";
      "diagnostic.info" = curl "info";
      "diagnostic.hint" = curl "hint";
      "diagnostic.unnecessary".modifiers = [ "dim" ];
      "diagnostic.deprecated".modifiers = [ "crossed_out" ];

      error = "error";
      warning = "warning";
      info = "info";
      hint = "hint";

      rainbow = [
        "rainbow0"
        "rainbow1"
        "rainbow2"
        "rainbow3"
        "rainbow4"
        "rainbow5"
      ];

      # Helix resolves every name above against this table, so the six rainbow
      # steps and the derived shades have to appear in it as entries.
      palette =
        p.named
        // derived
        // lib.listToAttrs (
          lib.imap0 (i: colour: lib.nameValuePair "rainbow${toString i}" colour) p.decorative.rainbow
        );
    };
in
{
  description = "helix";

  transparency = true;

  # helix resolves its own themes by name, so where it ships one there is
  # nothing to write: the config just points at it.
  integration.upstream.transparent = true;

  resolveName =
    {
      name,
      upstream,
      cfg,
    }:
    if upstream != null && cfg.transparent then "${name}-transparent" else name;

  # Helix ships hand-tuned themes for most of what orchard carries, written
  # against its own treesitter queries — around ninety scopes where the
  # generated theme below reaches sixty, and kept in step with the grammars as
  # they change. Where one exists it is inherited rather than replaced, which is
  # also how helix builds its own variants: `gruvbox_dark_hard` is `inherits =
  # "gruvbox"` and a palette. Only the themes helix has never heard of —
  # evergarden, luna — are generated from the palette.
  theme =
    {
      p,
      cfg,
      upstream,
      name,
      ...
    }:
    if upstream != null then
      {
        # Only reached when the background has to come off; otherwise the
        # config names the built-in and no file is written at all. `name` is
        # the built-in, and the file this lands in is `<name>-transparent`, so
        # this is not a theme inheriting itself.
        inherits = upstream;

        # Helix's own recipe for a see-through variant: an empty ui.background
        # leaves both the foreground and the fill to the terminal.
        "ui.background" = { };
      }
    else
      theme {
        inherit p;
        inherit (cfg) transparent;
      };

  hjem = {
    when = { config, ... }: config.rum.programs.helix.enable;

    config =
      {
        data,
        name,
        cfg,
        upstream,
        ...
      }:
      lib.mkMerge [
        { rum.programs.helix.settings.theme = lib.mkDefault name; }
        (lib.mkIf (upstream == null || cfg.transparent) {
          rum.programs.helix.themes.${name} = data;
        })
      ];
  };

  home = {
    when = { config, ... }: config.programs.helix.enable;

    config =
      {
        data,
        name,
        cfg,
        upstream,
        ...
      }:
      lib.mkMerge [
        { programs.helix.settings.theme = lib.mkDefault name; }
        (lib.mkIf (upstream == null || cfg.transparent) {
          programs.helix.themes.${name} = data;
        })
      ];
  };
}
