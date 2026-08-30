{ lib, render }:

let
  tmRule = name: scope: settings: { inherit name scope settings; };
  fg = color: { foreground = color; };
  plain = color: {
    foreground = color;
    fontStyle = "";
  };

  tmThemeRules = p: [
    (tmRule "Evergarden keywords" "keyword, keyword.control, storage, storage.type, storage.modifier" {
      foreground = p.syntax.keyword;
      fontStyle = "italic";
    })
    (tmRule "Evergarden keyword operators" "keyword.operator" {
      foreground = p.hue.orange;
      fontStyle = "";
    })
    (tmRule "Evergarden annotations and directives"
      "entity.other.attribute-name, variable.annotation, punctuation.definition.annotation, meta.preprocessor keyword, keyword.control.directive, keyword.other.directive"
      {
        foreground = p.syntax.annotation;
        fontStyle = "";
      }
    )
    (tmRule "Evergarden functions"
      "entity.name.function, variable.function, meta.function-call entity.name.function"
      (fg p.syntax.function)
    )
    (tmRule "Evergarden built-in functions" "support.function, support.function.builtin" {
      foreground = p.hue.orange;
      fontStyle = "";
    })
    (tmRule "Evergarden built-in variables" "variable.language" (fg p.syntax.constant))
    (tmRule "Evergarden function macros"
      "support.function.macro, entity.name.function.macro, meta.function-call.macro"
      {
        foreground = p.hue.aqua;
        fontStyle = "";
      }
    )
    (tmRule "Evergarden preprocessor macros"
      "meta.preprocessor, entity.name.function.preprocessor, entity.name.constant.preprocessor"
      {
        foreground = p.syntax.annotation;
        fontStyle = "";
      }
    )
    (tmRule "Evergarden types"
      "entity.name.type, entity.name.class, entity.name.struct, entity.name.enum, support.class, support.type, entity.other.inherited-class"
      {
        foreground = p.syntax.type;
        fontStyle = "italic";
      }
    )
    (tmRule "Evergarden namespaces"
      "entity.name.namespace, support.other.namespace, entity.name.module, entity.name.package"
      (fg p.syntax.module)
    )
    (tmRule "Evergarden properties"
      "variable.other.member, variable.other.property, support.type.property-name, meta.object-literal.key, entity.name.tag.yaml"
      (fg p.syntax.property)
    )
    (tmRule "Evergarden special strings"
      "string.other.symbol, constant.other.symbol, constant.other.key, string.interpolated"
      (fg p.syntax.special)
    )
    (tmRule "Evergarden documentation strings" "string.quoted.docstring, string.quoted.docstring.multi"
      {
        foreground = p.hue.skye;
        fontStyle = "";
      }
    )
    (tmRule "Evergarden URLs and paths"
      "markup.underline.link, markup.link, string.other.link, string.unquoted.path"
      {
        foreground = p.hue.blue;
        fontStyle = "";
      }
    )
    (tmRule "Evergarden raw markup" "markup.raw, markup.raw.inline, markup.raw.block, markup.inline.raw"
      (fg p.surface.neutral4)
    )
    (tmRule "Evergarden bold markup" "markup.bold" {
      foreground = p.hue.aqua;
      fontStyle = "bold";
    })
    (tmRule "Evergarden italic markup" "markup.italic" {
      foreground = p.hue.skye;
      fontStyle = "italic";
    })
    (tmRule "Evergarden quoted markup" "markup.quote" {
      foreground = p.syntax.comment;
      fontStyle = "italic";
    })
    (tmRule "Evergarden checked list items" "markup.list.checked" (fg p.status.success))
    (tmRule "Evergarden headings" "entity.name.section, markup.heading" {
      foreground = p.syntax.annotation;
      fontStyle = "";
    })
    (tmRule "Evergarden heading 1" "markup.heading.1" (plain (lib.elemAt p.decorative.rainbow 0)))
    (tmRule "Evergarden heading 2" "markup.heading.2" (plain (lib.elemAt p.decorative.rainbow 1)))
    (tmRule "Evergarden heading 3" "markup.heading.3" (plain (lib.elemAt p.decorative.rainbow 2)))
    (tmRule "Evergarden heading 4" "markup.heading.4" (plain (lib.elemAt p.decorative.rainbow 3)))
    (tmRule "Evergarden heading 5" "markup.heading.5" (plain (lib.elemAt p.decorative.rainbow 4)))
    (tmRule "Evergarden heading 6" "markup.heading.6" (plain (lib.elemAt p.decorative.rainbow 5)))
  ];
in
{
  description = "Comfy & fancy, warm and green";
  source = "https://codeberg.org/evergarden/nvim";

  palettes = import ./palettes.nix;

  defaultFlavor = "fall";

  # Summer is the only variant whose ramp runs the other way.
  lightFlavors = [ "summer" ];

  # Drawn in the engine's own vocabulary, so every hue doubles as an accent.
  accents = lib.genAttrs [
    "red"
    "orange"
    "yellow"
    "lime"
    "green"
    "aqua"
    "skye"
    "snow"
    "blue"
    "purple"
    "pink"
    "cherry"
  ] lib.id;

  defaultAccent = "green";

  # helix has never heard of evergarden, so its theme is written by hand.
  ports = {
    helix =
      { p, lib, ... }:
      data: data // import ./helix.nix { inherit p lib; };

    # Syntect sees TextMate scopes rather than Tree-sitter captures, so add the
    # closest equivalents of Evergarden's deliberately specific capture map.
    bat =
      {
        p,
        name,
        ...
      }:
      _:
      render.mkTmTheme {
        inherit name p;
        extraRules = tmThemeRules p;
      };
  };

  colours = { raw, ... }: raw;

  # evergarden.nvim's choices where they differ from the engine defaults.
  roles = p: {
    annotation = p.cherry;
    module = p.snow;
    inlineCode = p.overlay1;

    statusBg = p.mantle;
    statusFg = p.subtext0;
    statusDim = p.overlay1;
  };
}
