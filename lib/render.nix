{ lib }:

rec {
  noHash = lib.removePrefix "#";

  channels =
    colour:
    let
      bare = noHash colour;
      at = i: (builtins.fromTOML "v = 0x${builtins.substring i 2 bare}").v;
    in
    [
      (at 0)
      (at 2)
      (at 4)
    ];

  fromChannels =
    values:
    "#"
    + lib.concatMapStrings (
      value:
      let
        clamped =
          if value < 0 then
            0
          else if value > 255 then
            255
          else
            value;
        digits = "0123456789abcdef";
      in
      builtins.substring (clamped / 16) 1 digits + builtins.substring (lib.mod clamped 16) 1 digits
    ) values;

  # whiskers' `mix`: several upstream themes derive surfaces this way, not by name.
  mix =
    { colour, over }:
    amount:
    fromChannels (
      lib.zipListsWith (a: b: builtins.floor (a * amount + b * (1.0 - amount) + 0.5)) (channels colour) (
        channels over
      )
    );

  # RON, which is what rmpc reads.
  toRon =
    indent: v:
    let
      deeper = indent + "    ";
    in
    if lib.isAttrs v then
      (
        # A struct of plain values stays on one line; anything nested breaks.
        if lib.all (x: !lib.isAttrs x) (lib.attrValues v) then
          "(${lib.concatStringsSep ", " (lib.mapAttrsToList (k: x: "${k}: ${toRon indent x}") v)})"
        else
          "(\n${
            lib.concatStringsSep ",\n" (lib.mapAttrsToList (k: x: "${deeper}${k}: ${toRon deeper x}") v)
          },\n${indent})"
      )
    else if lib.isList v then
      "[${lib.concatMapStringsSep ", " (toRon indent) v}]"
    else if lib.isBool v then
      lib.boolToString v
    else if v == null then
      "None"
    else if lib.isString v then
      ''"${v}"''
    else
      toString v;

  # Enough KDL for zellij's themes block: every leaf is a quoted string.
  toKdl =
    indent: value:
    if lib.isAttrs value then
      lib.concatStringsSep "\n" (
        lib.mapAttrsToList (
          key: inner:
          if lib.isAttrs inner then
            "${indent}${key} {\n${toKdl (indent + "    ") inner}\n${indent}}"
          else
            "${indent}${key} \"${toString inner}\""
        ) value
      )
    else
      "${indent}${toString value}";

  # A Sublime `.tmTheme`, which is what bat, yazi and delta all read.
  mkTmTheme =
    { name, p }:
    let
      settings =
        attrs:
        lib.concatStringsSep "\n" (
          lib.mapAttrsToList (k: v: "\t\t\t\t<key>${k}</key>\n\t\t\t\t<string>${v}</string>") attrs
        );

      rule = scopeName: scope: attrs: ''
        		<dict>
        			<key>name</key>
        			<string>${scopeName}</string>
        			<key>scope</key>
        			<string>${scope}</string>
        			<key>settings</key>
        			<dict>
        ${settings attrs}
        			</dict>
        		</dict>'';

      # The first entry carries no scope; syntect reads it as the defaults.
      global = ''
        		<dict>
        			<key>settings</key>
        			<dict>
        ${settings {
          background = p.surface.background;
          foreground = p.surface.text;
          caret = p.ui.cursor;
          lineHighlight = p.ui.cursorLine;
          selection = p.ui.selection;
          invisibles = p.surface.neutral3;
          gutterForeground = p.surface.neutral2;
        }}
        			</dict>
        		</dict>'';

      rules = [
        global
        (rule "Comment" "comment, punctuation.definition.comment" {
          foreground = p.syntax.comment;
          fontStyle = "italic";
        })
        # tmTheme takes the longest selector, so this keeps quotes the string colour.
        (rule "String" "string, string.quoted, punctuation.definition.string, markup.raw, markup.inline.raw"
          {
            foreground = p.syntax.string;
          }
        )
        (rule "String escape and regexp" "constant.character.escape, string.regexp" {
          foreground = p.syntax.escape;
        })
        (rule "Keyword" "keyword, keyword.control, storage, storage.type, storage.modifier" {
          foreground = p.syntax.keyword;
        })
        (rule "Operator" "keyword.operator" { foreground = p.syntax.operator; })
        (rule "Number and language constant" "constant.numeric, constant.language" {
          foreground = p.syntax.number;
        })
        (rule "Constant" "constant.other, support.constant, variable.other.constant" {
          foreground = p.syntax.constant;
        })
        (rule "Function" "entity.name.function, support.function, meta.function-call, variable.function" {
          foreground = p.syntax.function;
        })
        (rule "Macro" "support.macro, support.function.macro, entity.name.function.macro, meta.preprocessor"
          {
            foreground = p.syntax.macro;
          }
        )
        (rule "Type"
          "entity.name.type, entity.name.class, support.class, support.type, entity.other.inherited-class"
          {
            foreground = p.syntax.type;
          }
        )
        (rule "Namespace" "entity.name.namespace, support.other.namespace, entity.name.module" {
          foreground = p.syntax.module;
        })
        (rule "Import" "keyword.control.import, keyword.other.import, meta.import" {
          foreground = p.syntax.annotation;
        })
        (rule "Variable" "variable, variable.other" { foreground = p.syntax.variable; })
        (rule "Parameter" "variable.parameter" { foreground = p.syntax.variable; })
        (rule "Property"
          "meta.object-literal.key, support.type.property-name, entity.name.tag.yaml, variable.other.member"
          {
            foreground = p.syntax.property;
          }
        )
        (rule "Tag" "entity.name.tag" { foreground = p.syntax.property; })
        (rule "Attribute" "entity.other.attribute-name" { foreground = p.syntax.annotation; })
        (rule "Punctuation" "punctuation, meta.brace" { foreground = p.syntax.punctuation; })
        (rule "Heading" "entity.name.section, markup.heading" {
          foreground = lib.elemAt p.decorative.rainbow 0;
          fontStyle = "bold";
        })
        (rule "Bold" "markup.bold" {
          foreground = p.surface.text;
          fontStyle = "bold";
        })
        (rule "Italic" "markup.italic" { fontStyle = "italic"; })
        (rule "Link" "markup.underline.link, markup.link" {
          foreground = p.hue.blue;
          fontStyle = "underline";
        })
        (rule "List" "markup.list" { foreground = p.syntax.punctuation; })
        (rule "Diff inserted" "markup.inserted" { foreground = p.status.diffAdded; })
        (rule "Diff deleted" "markup.deleted" { foreground = p.status.diffDeleted; })
        (rule "Diff changed" "markup.changed" { foreground = p.status.diffChanged; })
        (rule "Invalid" "invalid, invalid.illegal" {
          foreground = p.surface.background;
          background = p.status.error;
        })
      ];
    in
    ''
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
      <dict>
      	<key>name</key>
      	<string>${name}</string>
      	<key>colorSpaceName</key>
      	<string>sRGB</string>
      	<key>settings</key>
      	<array>
      ${lib.concatStringsSep "\n" rules}
      	</array>
      	<key>uuid</key>
      	<string>${name}</string>
      </dict>
      </plist>
    '';
}
