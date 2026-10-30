{ lib, ... }:

let
  # nushell's own default theme, with each style on its nearest palette role.
  theme =
    p:
    let
      bold = fg: {
        inherit fg;
        attr = "b";
      };
    in
    {
      separator = p.surface.neutral4;
      leading_trailing_space_bg.attr = "n";
      header = bold p.ui.title;
      empty = p.hue.blue;
      bool = p.syntax.constant;
      int = p.syntax.number;
      float = p.syntax.number;
      filesize = p.syntax.number;
      duration = p.syntax.special;
      datetime = p.syntax.special;
      range = p.syntax.special;
      string = p.syntax.string;
      nothing = p.syntax.constant;
      binary = p.syntax.special;
      cell-path = p.surface.textMuted;
      row_index = bold p.ui.accent;
      record = p.surface.text;
      list = p.surface.text;
      closure = p.surface.text;
      block = p.surface.text;
      glob = p.surface.text;
      hints = p.surface.neutral3;
      search_result = {
        fg = p.surface.background;
        bg = p.ui.search;
      };

      shape_and = bold p.syntax.operator;
      shape_binary = bold p.syntax.special;
      shape_block = bold p.syntax.punctuation;
      shape_bool = p.syntax.constant;
      shape_closure = bold p.syntax.punctuation;
      shape_custom = p.syntax.function;
      shape_datetime = bold p.syntax.special;
      shape_directory = p.hue.aqua;
      shape_external = p.syntax.function;
      shape_external_resolved = bold p.syntax.function;
      shape_externalarg = p.surface.text;
      shape_filepath = p.hue.aqua;
      shape_flag = bold p.syntax.property;
      shape_float = bold p.syntax.number;
      shape_garbage = {
        fg = p.surface.background;
        bg = p.status.error;
        attr = "b";
      };
      shape_glob_interpolation = bold p.hue.aqua;
      shape_globpattern = bold p.hue.aqua;
      shape_int = bold p.syntax.number;
      shape_internalcall = bold p.syntax.function;
      shape_keyword = bold p.syntax.keyword;
      shape_list = bold p.syntax.punctuation;
      shape_literal = p.syntax.constant;
      shape_match_pattern = p.syntax.special;
      shape_matching_brackets.attr = "u";
      shape_nothing = p.syntax.constant;
      shape_operator = p.syntax.operator;
      shape_or = bold p.syntax.operator;
      shape_pipe = bold p.syntax.operator;
      shape_range = bold p.syntax.special;
      shape_raw_string = p.syntax.string;
      shape_record = bold p.syntax.punctuation;
      shape_redirection = bold p.syntax.operator;
      shape_signature = bold p.syntax.type;
      shape_string = p.syntax.string;
      shape_string_interpolation = bold p.syntax.escape;
      shape_table = bold p.syntax.punctuation;
      shape_vardecl = p.syntax.variable;
      shape_variable = p.syntax.variable;
    };

  # A record merged over whatever color_config holds, so user styles still win.
  value =
    v:
    if lib.isAttrs v then
      "{ ${lib.concatStringsSep ", " (lib.mapAttrsToList (k: x: "${k}: ${value x}") v)} }"
    else
      ''"${v}"'';

  emit = data: ''
    $env.config.color_config = ($env.config.color_config | merge ${value data})
  '';
in
{
  description = "nushell";

  theme = { p, ... }: theme p;

  hjem = {
    when = { config, ... }: config.rum.programs.nushell.enable;

    config =
      { data, ... }:
      {
        rum.programs.nushell.extraConfig = lib.mkBefore (emit data);
      };
  };

  home = {
    when = { config, ... }: config.programs.nushell.enable;

    config =
      { data, ... }:
      {
        programs.nushell.extraConfig = lib.mkBefore (emit data);
      };
  };
}
