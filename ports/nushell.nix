{ lib, ... }:

let
  # catppuccin/nushell's scheme, in palette roles: commands that resolve in the
  # function colour and those that do not in plain text, arguments and
  # strings alike, flags and variables in italics, operators and pipes in
  # one colour, punctuation receding, and bold only for table headers.
  theme =
    p:
    let
      italic = fg: {
        inherit fg;
        attr = "i";
      };
      recognized = p.syntax.function;
      unrecognized = p.surface.text;
      constant = p.syntax.number;
      punctuation = p.surface.neutral5;
      operator = p.syntax.operator;
      string = p.syntax.string;
      virtual = p.surface.neutral2;
      variable = italic p.syntax.variable;
      filepath = p.hue.yellow;
    in
    {
      separator = {
        fg = virtual;
        attr = "b";
      };
      leading_trailing_space_bg = {
        fg = p.ui.accent;
        attr = "u";
      };
      header = {
        fg = p.surface.text;
        attr = "b";
      };
      row_index = virtual;
      record = p.surface.text;
      list = p.surface.text;
      hints = virtual;
      search_result = {
        fg = p.surface.background;
        bg = p.ui.search;
      };
      empty.attr = "n";
      closure = p.syntax.special;
      block = recognized;
      glob = filepath;
      cell-path = punctuation;
      bool = constant;
      int = constant;
      float = constant;
      nothing = constant;
      binary = constant;
      filesize = constant;
      duration = constant;
      datetime = constant;
      range = operator;
      string = string;

      shape_closure = p.syntax.special;
      shape_flag = italic p.syntax.property;
      shape_matching_brackets.attr = "u";
      shape_garbage = p.status.error;
      shape_keyword = p.syntax.keyword;
      shape_match_pattern = string;
      shape_signature = p.syntax.type;
      shape_table = punctuation;
      shape_list = punctuation;
      shape_record = punctuation;
      shape_block = recognized;
      shape_vardecl = variable;
      shape_variable = variable;
      shape_external = unrecognized;
      shape_internalcall = recognized;
      shape_external_resolved = recognized;
      shape_custom = p.syntax.macro;
      shape_range = operator;
      shape_pipe = operator;
      shape_operator = operator;
      shape_redirection = operator;
      shape_and = operator;
      shape_or = operator;
      shape_directory = filepath;
      shape_filepath = filepath;
      shape_glob_interpolation = filepath;
      shape_globpattern = filepath;
      shape_int = constant;
      shape_bool = constant;
      shape_float = constant;
      shape_binary = constant;
      shape_datetime = constant;
      shape_literal = constant;
      shape_nothing = constant;
      shape_string = string;
      shape_string_interpolation = p.syntax.escape;
      shape_raw_string = string;
      shape_externalarg = string;
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
    $env.config.highlight_resolved_externals = true
  '';
in
{
  description = "nushell";

  # Upstream themes (catppuccin/nushell) are sourced as they are.
  integration = { };

  theme = { p, ... }: theme p;

  hjem = {
    when = { config, ... }: config.rum.programs.nushell.enable;

    config =
      { data, provider, ... }:
      {
        rum.programs.nushell.extraConfig = lib.mkBefore (
          if provider != null && provider ? file then "source ${provider.file}\n" else emit data
        );
      };
  };

  home = {
    when = { config, ... }: config.programs.nushell.enable;

    config =
      { data, provider, ... }:
      {
        programs.nushell.extraConfig = lib.mkBefore (
          if provider != null && provider ? file then "source ${provider.file}\n" else emit data
        );
      };
  };
}
