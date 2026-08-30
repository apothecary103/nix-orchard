{ lib }:

rec {
  # A theme has to spell all of these; ports read the grouped palette instead.
  surfaces = [
    "crust"
    "mantle"
    "base"
    "surface0"
    "surface1"
    "surface2"
    "overlay0"
    "overlay1"
    "overlay2"
    "subtext0"
    "subtext1"
    "text"
  ];

  hues = [
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
  ];

  syntaxRoles = [
    "keyword"
    "func"
    "macro"
    "type"
    "constant"
    "number"
    "string"
    "escape"
    "escapeAlt"
    "inlineCode"
    "special"
    "variable"
    "property"
    "module"
    "annotation"
    "operator"
    "punctuation"
    "comment"
  ];

  uiRoles = [
    "accent"
    "cursor"
    "selection"
    "cursorline"
    "search"
    "match"
    "title"
    "secondaryAccent"
  ];

  statusRoles = [
    "error"
    "errorMuted"
    "warning"
    "info"
    "hint"
    "ok"
    "add"
    "delete"
    "change"
  ];

  statusBarRoles = [
    "statusBg"
    "statusFg"
    "statusInactive"
    "statusDim"
    "statusModeFg"
    "statusModeNormal"
    "statusModeInsert"
    "statusModeSelect"
  ];

  publicSyntaxRoles = (lib.remove "func" syntaxRoles) ++ [ "function" ];

  publicUiRoles = (lib.remove "cursorline" uiRoles) ++ [ "cursorLine" ];

  publicStatusRoles =
    (lib.subtractLists [
      "ok"
      "add"
      "delete"
      "change"
    ] statusRoles)
    ++ [
      "success"
      "diffAdded"
      "diffDeleted"
      "diffChanged"
    ];

  # Defaults a theme may override; the rest fall out of the twelve hues.
  roles = c: {
    cursor = c.accent;
    selection = c.surface1;
    cursorline = c.surface0;
    comment = c.overlay2;

    keyword = c.red;
    func = c.green;
    macro = c.cherry;
    type = c.yellow;
    constant = c.pink;
    number = c.pink;
    string = c.lime;
    escape = c.yellow;
    escapeAlt = c.red;
    inlineCode = c.red;
    special = c.aqua;
    variable = c.text;
    property = c.skye;
    module = c.snow;
    annotation = c.cherry;
    operator = c.subtext0;
    punctuation = c.overlay1;

    error = c.red;
    errorMuted = c.red;
    warning = c.yellow;
    info = c.aqua;
    hint = c.skye;
    ok = c.green;

    add = c.green;
    delete = c.red;
    change = c.aqua;

    search = c.snow;
    match = c.orange;
    title = c.cherry;
    secondaryAccent = c.blue;

    # Every project picks its status bar rather than deriving it, so it gets roles.
    statusBg = c.mantle;
    statusFg = c.text;
    statusInactive = c.subtext0;
    statusDim = c.overlay1;
    statusModeFg = c.base;
    statusModeNormal = c.accent;
    statusModeInsert = c.ok;
    statusModeSelect = c.info;

    rainbow = [
      c.red
      c.orange
      c.yellow
      c.green
      c.aqua
      c.blue
    ];

    # Slots 0, 7, 8 and 15 are the grey ramp, so "black" flips on a light flavor.
    ansi = [
      (if c.isLight then c.subtext1 else c.surface1)
      c.red
      c.green
      c.yellow
      c.blue
      c.pink
      c.aqua
      (if c.isLight then c.surface2 else c.subtext0)
      c.overlay1
      c.red
      c.green
      c.yellow
      c.blue
      c.pink
      c.aqua
      (if c.isLight then c.surface0 else c.subtext1)
    ];
  };

  flavorsOf = theme: lib.attrNames theme.palettes;

  accentsOf = theme: lib.attrNames theme.accents;

  # Flavors end up side by side in a themes directory, so only they need suffixing.
  nameOf =
    theme: flavor: if lib.length (flavorsOf theme) > 1 then "${theme.name}-${flavor}" else theme.name;

  mkPalette =
    theme:
    { flavor, accent }:
    let
      raw = theme.palettes.${flavor};
      isLight = lib.elem flavor (theme.lightFlavors or [ ]);

      colours = theme.colours { inherit raw isLight flavor; } // {
        inherit isLight raw;
      };

      chosen = theme.accents.${accent};
      accentColour = if lib.hasPrefix "#" chosen then chosen else colours.${chosen};

      # One fixed point, so any of these can name any other in any order.
      flat = lib.fix (
        self: colours // roles self // (theme.roles or (_: { })) self // { accent = accentColour; }
      );

      aliases = {
        function = flat.func;
        cursorLine = flat.cursorline;
        success = flat.ok;
        diffAdded = flat.add;
        diffDeleted = flat.delete;
        diffChanged = flat.change;
      };

      resolved = flat // aliases;
    in
    {
      surface = {
        shadow = flat.crust;
        panel = flat.mantle;
        background = flat.base;
        neutral0 = flat.surface0;
        neutral1 = flat.surface1;
        neutral2 = flat.surface2;
        neutral3 = flat.overlay0;
        neutral4 = flat.overlay1;
        neutral5 = flat.overlay2;
        textDim = flat.subtext0;
        textMuted = flat.subtext1;
        text = flat.text;
      };
      hue = lib.getAttrs hues flat;
      syntax = lib.getAttrs publicSyntaxRoles resolved;
      ui = lib.getAttrs publicUiRoles resolved;
      status = lib.getAttrs publicStatusRoles resolved;
      statusBar = {
        background = flat.statusBg;
        foreground = flat.statusFg;
        inactive = flat.statusInactive;
        dim = flat.statusDim;
        mode = {
          foreground = flat.statusModeFg;
          normal = flat.statusModeNormal;
          insert = flat.statusModeInsert;
          select = flat.statusModeSelect;
        };
      };
      decorative.rainbow = flat.rainbow;
      terminal.ansi = flat.ansi;

      # For helix, starship and vivid, which resolve styles by key not by value.
      named =
        lib.getAttrs (surfaces ++ hues ++ syntaxRoles ++ uiRoles ++ statusRoles ++ statusBarRoles) flat
        // aliases;

      # The theme's own vocabulary, where a colour has no portable name.
      native = raw;

      inherit isLight;
    };
}
