# luna for helix, written against luna.nvim's own treesitter groups. Luna is a
# near-monochrome theme: identifiers, properties and members are all plain
# foreground, punctuation and operators sit on the grey ramp, and only four
# hues — keyword, func, type, string — ever appear. Getting that restraint right
# matters more than covering every scope with a different colour.
{ p, lib }:

let
  raw = p.raw;

  italic = fg: {
    inherit fg;
    modifiers = [ "italic" ];
  };

  bold = fg: {
    inherit fg;
    modifiers = [ "bold" ];
  };

  curl = colour: {
    underline = {
      color = colour;
      style = "curl";
    };
  };
in
{
  # Syntax
  "comment" = italic "comment";
  "comment.block.documentation" = italic "comment";

  # Identifier, Property and Variable are all `fg` upstream — the theme leans on
  # weight and the four accents, not on colouring every name.
  "variable" = "text";
  "variable.parameter" = "text";
  "variable.builtin" = "type";
  "variable.other.member" = "text";

  "constant" = "type";
  "constant.builtin" = "type";
  "constant.numeric" = "keyword";
  "constant.character" = "string";
  "constant.character.escape" = "special";

  "string" = "string";
  "string.regexp" = "string";
  "string.special" = "operator";
  "string.special.url" = "ok";
  "string.special.path" = "ok";
  "string.special.symbol" = "operator";

  "keyword" = "keyword";
  "keyword.control" = "keyword";
  "keyword.control.conditional" = "keyword";
  "keyword.control.return" = "keyword";
  "keyword.control.exception" = "keyword";
  "keyword.control.import" = raw.grey_warm;
  "keyword.operator" = "operator";
  "keyword.directive" = "comment";
  "keyword.storage" = "keyword";
  "keyword.function" = "keyword";

  "operator" = "operator";

  "function" = "func";
  "function.builtin" = "func";
  "function.method" = "func";
  "function.macro" = "keyword";
  "constructor" = "type";

  "type" = "type";
  "type.builtin" = "keyword";
  "type.parameter" = "type";
  "type.enum.variant" = "type";

  "attribute" = "comment";
  "namespace" = "module";
  "label" = "keyword";
  "special" = "operator";
  "tag" = "keyword";
  "tag.builtin" = "keyword";

  "punctuation" = "punctuation";
  "punctuation.bracket" = "operator";
  "punctuation.delimiter" = "operator";
  "punctuation.special" = "operator";

  # Markup — luna's heading ramp runs silver, pale, type, light, light, silver
  # rather than through hues, because it has none to spend.
  "markup.heading" = bold "title";
  "markup.heading.1" = bold raw.silver;
  "markup.heading.2" = bold raw.grey_pale;
  "markup.heading.3" = bold "type";
  "markup.heading.4" = bold raw.grey_light;
  "markup.heading.5" = bold raw.grey_light;
  "markup.heading.6" = bold raw.silver;
  "markup.bold" = bold raw.grey_light;
  "markup.italic".modifiers = [ "italic" ];
  "markup.strikethrough".modifiers = [ "crossed_out" ];
  "markup.link.url" = {
    fg = "ok";
    modifiers = [
      "italic"
      "underlined"
    ];
  };
  "markup.link.text" = "ok";
  "markup.link.label" = "operator";
  "markup.raw" = "string";
  "markup.quote" = italic "comment";
  "markup.list" = "operator";
  "markup.list.checked" = "ok";
  "markup.list.unchecked" = "func";

  "diff.plus" = "add";
  "diff.minus" = "delete";
  "diff.delta" = "change";

  # Interface
  "ui.linenr".fg = raw.line_nr;
  "ui.linenr.selected".fg = raw.silver;

  "ui.statusline" = {
    fg = "statusFg";
    bg = "statusBg";
  };
  "ui.statusline.inactive" = {
    fg = "statusDim";
    bg = "statusBg";
  };
  "ui.statusline.normal" = {
    fg = "crust";
    bg = "accent";
    modifiers = [ "bold" ];
  };
  "ui.statusline.insert" = {
    fg = "crust";
    bg = "ok";
    modifiers = [ "bold" ];
  };
  "ui.statusline.select" = {
    fg = "crust";
    bg = "info";
    modifiers = [ "bold" ];
  };

  "ui.popup" = {
    fg = "text";
    bg = raw.float_bg;
  };
  "ui.window".fg = raw.border;
  "ui.help" = {
    fg = "text";
    bg = raw.float_bg;
  };

  "ui.bufferline" = {
    fg = "subtext0";
    bg = "mantle";
  };
  "ui.bufferline.active" = {
    fg = "text";
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
    bg = raw.selection;
    modifiers = [ "bold" ];
  };
  "ui.text.inactive".fg = "overlay1";
  "ui.text.directory".fg = "func";

  "ui.virtual" = "overlay0";
  "ui.virtual.ruler".bg = raw.cursor_line;
  "ui.virtual.indent-guide" = raw.line_nr;
  "ui.virtual.inlay-hint" = italic "overlay0";
  "ui.virtual.whitespace" = raw.line_nr;
  "ui.virtual.wrap" = "overlay0";

  # Search is fg_bright on the plum wash; the incremental match swaps to the
  # warm signal, which is also what the jump labels use.
  "ui.virtual.jump-label" = bold "match";
  "ui.cursor.match" = {
    fg = "base";
    bg = "match";
    modifiers = [ "bold" ];
  };

  "ui.selection" = {
    bg = raw.visual or raw.border;
  };
  "ui.highlight" = {
    fg = raw.fg_bright;
    bg = raw.bg_plum;
  };

  "ui.menu" = {
    fg = "text";
    bg = raw.float_bg;
  };
  "ui.menu.selected" = {
    fg = "text";
    bg = raw.selection;
    modifiers = [ "bold" ];
  };
  "ui.menu.scroll" = {
    fg = "overlay0";
    bg = raw.surface;
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
}
