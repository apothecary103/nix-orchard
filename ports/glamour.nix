{ lib, ... }:

let
  # catppuccin/glamour. Headings are blocked out with ▓ runs rather than #
  # prefixes, code sits on the mantle, and chroma follows the same grammar the
  # editor ports do.
  theme =
    p:
    let
      fg = colour: { color = colour; };

      heading = prefix: colour: {
        inherit prefix;
        color = colour;
      };
    in
    {
      document = {
        block_prefix = "\n";
        block_suffix = "\n";
        color = p.text;
        margin = 2;
      };

      block_quote = {
        indent = 1;
        indent_token = "│ ";
      };

      paragraph = { };
      list.level_indent = 2;

      heading = {
        block_suffix = "\n";
        color = p.text;
        bold = true;
      };
      h1 = {
        prefix = "▓▓▓ ";
        suffix = " ";
        color = lib.elemAt p.rainbow 0;
        bold = true;
      };
      h2 = heading "▓▓▓▓ " (lib.elemAt p.rainbow 1);
      h3 = heading "▓▓▓▓▓ " (lib.elemAt p.rainbow 2);
      h4 = heading "▓▓▓▓▓▓ " (lib.elemAt p.rainbow 3);
      h5 = heading "▓▓▓▓▓▓▓ " (lib.elemAt p.rainbow 4);
      h6 = heading "▓▓▓▓▓▓▓▓ " (lib.elemAt p.rainbow 5);

      text = { };
      strikethrough.crossed_out = true;
      emph.italic = true;
      strong.bold = true;

      hr = {
        color = p.overlay0;
        format = "\n--------\n";
      };

      item.block_prefix = "• ";
      enumeration.block_prefix = ". ";
      task = {
        ticked = "[✓] ";
        unticked = "[ ] ";
      };

      link = {
        color = p.blue;
        underline = true;
      };
      link_text = {
        color = p.lavender;
        bold = true;
      };
      image = {
        color = p.blue;
        underline = true;
      };
      image_text = {
        color = p.lavender;
        format = "Image: {{.text}} →";
      };

      code = {
        prefix = " ";
        suffix = " ";
        color = p.maroon;
        background_color = p.mantle;
      };

      code_block = {
        color = p.mantle;
        margin = 2;
        chroma = {
          text = fg p.text;
          error = {
            color = p.text;
            background_color = p.error;
          };
          comment = fg p.overlay0;
          comment_preproc = fg p.func;
          keyword = fg p.keyword;
          keyword_reserved = fg p.keyword;
          keyword_namespace = fg p.type;
          keyword_type = fg p.type;
          operator = fg p.operator;
          punctuation = fg p.overlay2;
          name = fg p.lavender;
          name_builtin = fg p.constant;
          name_tag = fg p.keyword;
          name_attribute = fg p.type;
          name_class = fg p.type;
          name_constant = fg p.type;
          name_decorator = fg p.pink;
          name_exception = { };
          name_function = fg p.func;
          name_other = { };
          literal = { };
          literal_number = fg p.number;
          literal_date = { };
          literal_string = fg p.string;
          literal_string_escape = fg p.escape;
          generic_deleted = fg p.delete;
          generic_emph = {
            color = p.text;
            italic = true;
          };
          generic_inserted = fg p.add;
          generic_strong = {
            color = p.text;
            bold = true;
          };
          generic_subheading = fg p.skye;
          background.background_color = p.mantle;
        };
      };

      table = {
        center_separator = "┼";
        column_separator = "│";
        row_separator = "─";
      };
      definition_list = { };
      definition_term = { };
      definition_description.block_prefix = "\n🠶 ";
      html_block = { };
      html_span = { };
    };
in
{
  # glow, gh and the other charm tools read this through $GLAMOUR_STYLE rather
  # than a module of their own, so there is no program to hang the port off.
  description = "glamour, the charm markdown renderer";

  program = "glow";

  theme = { p, ... }: theme p;

  hjem =
    {
      pkgs,
      data,
      name,
      ...
    }:
    {
      environment.sessionVariables.GLAMOUR_STYLE = "${(pkgs.formats.json { }).generate
        "${name}-glamour.json"
        data
      }";
    };

  home =
    {
      pkgs,
      data,
      name,
      ...
    }:
    {
      home.sessionVariables.GLAMOUR_STYLE = "${(pkgs.formats.json { }).generate "${name}-glamour.json"
        data
      }";
    };
}
