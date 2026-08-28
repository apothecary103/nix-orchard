# evergarden for helix, against evergarden.nvim's own treesitter groups.
{ p, lib }:

let
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
  "comment" = italic "overlay2";
  "comment.block.documentation" = italic "overlay2";

  "variable" = "text";
  "variable.parameter" = "text";
  "variable.builtin" = "constant";
  "variable.other.member" = "property";

  "constant" = "constant";
  "constant.builtin" = "constant";
  "constant.numeric" = "constant";
  "constant.character" = "string";
  "constant.character.escape" = "escape";

  "string" = "string";
  "string.regexp" = "escape";
  "string.special" = "special";
  "string.special.url" = "info";
  "string.special.path" = "info";
  "string.special.symbol" = "special";

  "keyword" = italic "keyword";
  "keyword.control" = italic "keyword";
  "keyword.control.conditional" = italic "keyword";
  "keyword.control.import" = "annotation";
  "keyword.control.return" = italic "keyword";
  "keyword.operator" = "orange";
  "keyword.directive" = "annotation";
  "keyword.storage" = italic "keyword";
  "keyword.storage.modifier" = italic "keyword";
  "keyword.function" = italic "keyword";

  "operator" = "operator";

  "function" = "func";
  "function.builtin" = "orange";
  "function.macro" = "macro";
  "function.method" = "func";
  "constructor" = "func";

  "type" = "type";
  "type.builtin" = "type";
  "type.parameter" = "type";
  "type.enum.variant" = "constant";

  "attribute" = "annotation";
  "namespace" = "module";
  "label" = "special";
  "special" = "special";
  "tag" = "property";
  "tag.builtin" = "property";

  # Brackets and delimiters sit on the dimmest syntax step upstream has.
  "punctuation" = "punctuation";
  "punctuation.bracket" = "punctuation";
  "punctuation.delimiter" = "punctuation";
  "punctuation.special" = "special";

  "markup.heading" = bold "title";
  "markup.heading.1" = bold "rainbow0";
  "markup.heading.2" = bold "rainbow1";
  "markup.heading.3" = bold "rainbow2";
  "markup.heading.4" = bold "rainbow3";
  "markup.heading.5" = bold "rainbow4";
  "markup.heading.6" = bold "rainbow5";
  "markup.bold" = bold "aqua";
  "markup.italic" = italic "skye";
  "markup.strikethrough".modifiers = [ "crossed_out" ];
  "markup.link.url" = {
    fg = "info";
    modifiers = [
      "italic"
      "underlined"
    ];
  };
  "markup.link.text" = "info";
  "markup.link.label" = italic "skye";
  "markup.raw" = "overlay1";
  "markup.quote" = italic "overlay2";
  "markup.list" = "punctuation";
  "markup.list.checked" = "ok";
  "markup.list.unchecked" = "punctuation";

  "diff.plus" = "add";
  "diff.minus" = "delete";
  "diff.delta" = "change";

  "ui.linenr".fg = "surface2";
  "ui.linenr.selected".fg = "overlay2";

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
    bg = "mantle";
  };
  "ui.window".fg = "surface1";
  "ui.help" = {
    fg = "subtext0";
    bg = "mantle";
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
  "ui.virtual.indent-guide" = "surface1";
  "ui.virtual.inlay-hint" = italic "overlay0";
  "ui.virtual.whitespace" = "surface2";
  "ui.virtual.wrap" = "surface2";

  # `incsearch` is orange upstream and `search` snow; the jump labels follow.
  "ui.virtual.jump-label" = bold "match";
  "ui.cursor.match" = bold "match";

  "ui.selection".bg = "selection";
  "ui.highlight".bg = "surface1";

  "ui.menu" = {
    fg = "subtext0";
    bg = "mantle";
  };
  "ui.menu.selected" = {
    fg = "text";
    bg = "surface1";
    modifiers = [ "bold" ];
  };
  "ui.menu.scroll" = {
    fg = "overlay0";
    bg = "surface0";
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
