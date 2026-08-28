{ lib, ... }:

{
  description = "GNOME's palette, on GNOME's own surfaces";
  source = "https://github.com/helix-editor/helix/tree/master/runtime/themes";

  palettes = import ./palettes.nix;

  defaultFlavor = "dark";
  lightFlavors = [ "light" ];

  accents = lib.genAttrs [
    "blue"
    "teal"
    "green"
    "yellow"
    "orange"
    "red"
    "purple"
    "violet"
    "brown"
  ] lib.id;

  defaultAccent = "blue";

  # btop calls the light one plain `adwaita`; helix ships both.
  integrations = {
    helix = {
      kind = "builtin";
      name = flavor: "adwaita-${flavor}";
    };
    btop = {
      kind = "builtin";
      name = flavor: if flavor == "light" then "adwaita" else "adwaita-dark";
    };
  };

  colours =
    { raw, isLight, ... }:
    raw
    // (
      if isLight then
        {
          crust = raw.light_5;
          mantle = raw.light_3;
          base = raw.light_1;
          surface0 = raw.light_3;
          surface1 = raw.light_4;
          surface2 = raw.light_5;
          overlay0 = raw.light_6;
          overlay1 = raw.light_7;
          overlay2 = raw.dark_1;
          subtext0 = raw.dark_2;
          subtext1 = raw.dark_3;
          text = raw.dark_4;

          red = raw.red_4;
          orange = raw.orange_4;
          yellow = raw.yellow_5;
          lime = raw.green_4;
          green = raw.green_5;
          aqua = raw.teal_4;
          skye = raw.teal_3;
          snow = raw.blue_5;
          blue = raw.blue_4;
          purple = raw.purple_4;
          pink = raw.purple_3;
          cherry = raw.brown_4;
          teal = raw.teal_4;
          violet = raw.violet_4;
          brown = raw.brown_4;
        }
      else
        {
          crust = raw.dark_6;
          mantle = raw.libadwaita_dark_alt;
          base = raw.libadwaita_dark;
          surface0 = raw.libadwaita_popup;
          surface1 = raw.libadwaita_dark_alt;
          surface2 = raw.split_and_borders;
          overlay0 = raw.dark_3;
          overlay1 = raw.dark_2;
          overlay2 = raw.dark_1;
          subtext0 = raw.light_7;
          subtext1 = raw.light_5;
          text = raw.light_4;

          red = raw.red_1;
          orange = raw.orange_2;
          yellow = raw.yellow_2;
          lime = raw.green_2;
          green = raw.green_3;
          aqua = raw.teal_2;
          skye = raw.teal_1;
          snow = raw.blue_1;
          blue = raw.blue_2;
          purple = raw.purple_2;
          pink = raw.purple_1;
          cherry = raw.brown_1;
          teal = raw.teal_2;
          violet = raw.violet_2;
          brown = raw.brown_2;
        }
    );

  # GNOME Builder's scheme, as helix's adwaita themes spell it: bold orange
  # keywords, blue functions, teal strings and types, violet constants and a
  # purple operator — not the hue-derived defaults, which had none of this.
  roles = p: {
    comment = if p.isLight then p.raw.light_6 else p.raw.dark_2;

    keyword = if p.isLight then p.raw.orange_4 else p.raw.orange_2;
    func = p.blue;
    macro = p.pink;
    type = p.aqua;
    constant = p.violet;
    number = p.violet;
    string = if p.isLight then p.raw.teal_3 else p.raw.teal_2;
    escape = p.pink;
    special = p.pink;
    variable = p.text;
    property = p.snow;
    module = p.purple;
    annotation = p.cherry;
    operator = p.purple;
    punctuation = p.overlay2;

    error = p.red;
    warning = p.yellow;
    info = p.blue;
    hint = p.aqua;
    ok = p.green;

    add = p.green;
    delete = p.red;
    change = p.blue;

    search = p.yellow;
    match = p.orange;
    title = p.purple;

    cursor = if p.isLight then p.raw.dark_4 else p.raw.light_5;
    selection = if p.isLight then p.raw.blue_1 else p.raw.blue_7;

    statusBg = if p.isLight then p.raw.light_4 else p.raw.libadwaita_dark_alt;
    statusFg = p.text;
    statusDim = if p.isLight then p.raw.dark_1 else p.raw.light_7;

    rainbow = [
      p.red
      p.orange
      p.yellow
      p.green
      p.aqua
      p.blue
    ];

    # GNOME Console's palette, which is the same family at terminal contrast.
    ansi =
      if p.isLight then
        [
          "#241f31"
          "#c01c28"
          "#2ec27e"
          "#a2734c"
          "#1e78e4"
          "#9841bb"
          "#0ab9dc"
          "#c0bfbc"
          "#5e5c64"
          "#ed333b"
          "#57e389"
          "#e5a50a"
          "#51a1ff"
          "#c061cb"
          "#4fd2fd"
          "#f6f5f4"
        ]
      else
        [
          "#241f31"
          "#c01c28"
          "#2ec27e"
          "#a2734c"
          "#1e78e4"
          "#9841bb"
          "#0ab9dc"
          "#c0bfbc"
          "#5e5c64"
          "#ed333b"
          "#57e389"
          "#f8e45c"
          "#51a1ff"
          "#c061cb"
          "#4fd2fd"
          "#ffffff"
        ];
  };
}
