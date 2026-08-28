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
        color = p.surface.text;
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
        color = p.surface.text;
        bold = true;
      };
      h1 = {
        prefix = "▓▓▓ ";
        suffix = " ";
        color = lib.elemAt p.decorative.rainbow 0;
        bold = true;
      };
      h2 = heading "▓▓▓▓ " (lib.elemAt p.decorative.rainbow 1);
      h3 = heading "▓▓▓▓▓ " (lib.elemAt p.decorative.rainbow 2);
      h4 = heading "▓▓▓▓▓▓ " (lib.elemAt p.decorative.rainbow 3);
      h5 = heading "▓▓▓▓▓▓▓ " (lib.elemAt p.decorative.rainbow 4);
      h6 = heading "▓▓▓▓▓▓▓▓ " (lib.elemAt p.decorative.rainbow 5);

      text = { };
      strikethrough.crossed_out = true;
      emph.italic = true;
      strong.bold = true;

      hr = {
        color = p.surface.neutral3;
        format = "\n--------\n";
      };

      item.block_prefix = "• ";
      enumeration.block_prefix = ". ";
      task = {
        ticked = "[✓] ";
        unticked = "[ ] ";
      };

      link = {
        color = p.hue.blue;
        underline = true;
      };
      link_text = {
        color = p.ui.secondaryAccent;
        bold = true;
      };
      image = {
        color = p.hue.blue;
        underline = true;
      };
      image_text = {
        color = p.ui.secondaryAccent;
        format = "Image: {{.text}} →";
      };

      code = {
        prefix = " ";
        suffix = " ";
        color = p.syntax.inlineCode;
        background_color = p.surface.panel;
      };

      code_block = {
        color = p.surface.panel;
        margin = 2;
        chroma = {
          text = fg p.surface.text;
          error = {
            color = p.surface.text;
            background_color = p.status.error;
          };
          comment = fg p.surface.neutral3;
          comment_preproc = fg p.syntax.function;
          keyword = fg p.syntax.keyword;
          keyword_reserved = fg p.syntax.keyword;
          keyword_namespace = fg p.syntax.type;
          keyword_type = fg p.syntax.type;
          operator = fg p.syntax.operator;
          punctuation = fg p.surface.neutral5;
          name = fg p.ui.secondaryAccent;
          name_builtin = fg p.syntax.constant;
          name_tag = fg p.syntax.keyword;
          name_attribute = fg p.syntax.type;
          name_class = fg p.syntax.type;
          name_constant = fg p.syntax.type;
          name_decorator = fg p.hue.pink;
          name_exception = { };
          name_function = fg p.syntax.function;
          name_other = { };
          literal = { };
          literal_number = fg p.syntax.number;
          literal_date = { };
          literal_string = fg p.syntax.string;
          literal_string_escape = fg p.syntax.escape;
          generic_deleted = fg p.status.diffDeleted;
          generic_emph = {
            color = p.surface.text;
            italic = true;
          };
          generic_inserted = fg p.status.diffAdded;
          generic_strong = {
            color = p.surface.text;
            bold = true;
          };
          generic_subheading = fg p.hue.skye;
          background.background_color = p.surface.panel;
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
      environment.sessionVariables.GLAMOUR_STYLE = lib.mkDefault "${(pkgs.formats.json { }).generate
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
      home.sessionVariables.GLAMOUR_STYLE = lib.mkDefault "${(pkgs.formats.json { }).generate
        "${name}-glamour.json"
        data
      }";
    };
}
