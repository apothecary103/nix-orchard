{ lib }:

rec {
  # The standard vocabulary. A theme has to spell all of these; a port may only
  # ever name one of these or a role below, never a colour of its own.
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
    "statusDim"
  ];

  # Catppuccin's vocabulary, so a hand-styled config written against it resolves
  # under any theme. A theme that has its own value for one of these keeps it —
  # these are only the fallbacks.
  compat = c: {
    mauve = c.purple;
    lavender = c.blue;
    sapphire = c.skye;
    sky = c.skye;
    peach = c.orange;
    teal = c.aqua;
    maroon = c.red;
    rosewater = c.cherry;
    flamingo = c.cherry;
  };

  # What every port actually reads. A theme overrides whichever of these its own
  # design disagrees with; the rest fall out of the twelve hues.
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

    # Status bars are the one piece of chrome every project decides for itself
    # rather than deriving, so they get roles of their own instead of being
    # spelled out of the ramp at each port.
    statusBg = c.mantle;
    statusFg = c.subtext1;
    statusDim = c.overlay1;

    rainbow = [
      c.red
      c.orange
      c.yellow
      c.green
      c.aqua
      c.blue
    ];

    # Slots 0, 7, 8 and 15 are the grey ramp, so which end counts as "black"
    # flips on a light flavor.
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

  # A single-flavor theme is named after itself; anything else carries the
  # flavor, because the two end up side by side in a themes directory.
  nameOf =
    theme: flavor: if lib.length (flavorsOf theme) > 1 then "${theme.name}-${flavor}" else theme.name;

  # Layered as a fixed point so a theme's own roles can name each other and the
  # derived defaults alike, in any order.
  mkPalette =
    theme:
    { flavor, accent }:
    let
      raw = theme.palettes.${flavor};
      isLight = lib.elem flavor (theme.lightFlavors or [ ]);

      own = theme.colours { inherit raw isLight flavor; };
      colours = compat own // own // { inherit isLight raw; };

      named = theme.accents.${accent};
      accentColour = if lib.hasPrefix "#" named then named else colours.${named};
    in
    let
      flat = lib.fix (
        self: colours // roles self // (theme.roles or (_: { })) self // { accent = accentColour; }
      );
    in
    flat
    // {
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
      syntax = (lib.getAttrs syntaxRoles flat) // {
        function = flat.func;
      };
      ui = (lib.getAttrs uiRoles flat) // {
        cursorLine = flat.cursorline;
      };
      status = (lib.getAttrs statusRoles flat) // {
        success = flat.ok;
        diffAdded = flat.add;
        diffDeleted = flat.delete;
        diffChanged = flat.change;
      };
      statusBar = {
        background = flat.statusBg;
        foreground = flat.statusFg;
        dim = flat.statusDim;
      };
      decorative.rainbow = flat.rainbow;
      terminal.ansi = flat.ansi;

      # Flat string table for formats such as Helix, Starship and vivid which
      # resolve styles by a palette key. Unlike the legacy root, it contains no
      # theme-native or compatibility-only names.
      named = lib.getAttrs (
        surfaces ++ hues ++ syntaxRoles ++ uiRoles ++ statusRoles ++ statusBarRoles
      ) flat;

      # `native` is the theme's own vocabulary. `raw` and the flat palette are
      # retained as compatibility aliases while ports move to the semantic
      # namespaces above.
      native = raw;
      compat.catppuccin = compat flat;
    };
}
