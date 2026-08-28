{ lib, ... }:

{
  description = "gruvbox with the saturation taken off";
  source = "https://github.com/sainnhe/gruvbox-material";

  palettes = import ./palettes.nix;

  defaultFlavor = "dark";
  lightFlavors = [
    "light"
    "light-hard"
    "light-soft"
  ];

  accents = lib.genAttrs [
    "red"
    "orange"
    "yellow"
    "green"
    "aqua"
    "blue"
    "purple"
  ] lib.id;

  defaultAccent = "green";

  # Only helix and btop know it, and only in the dark.
  integrations = {
    helix = {
      kind = "builtin";
      name = flavor: if lib.hasPrefix "dark" flavor then "gruvbox-material" else null;
    };
    btop = {
      kind = "builtin";
      name = flavor: if lib.hasPrefix "dark" flavor then "gruvbox_material_dark" else null;
    };
  };

  colours = { raw, ... }: raw;

  # gruvbox-material's "material" highlight set: it keeps gruvbox's shape but
  # pushes functions to green-bold, types to yellow and constants to purple,
  # with aqua doing the work orange does in the original.
  roles = p: {
    comment = p.overlay1;

    keyword = p.red;
    func = p.green;
    macro = p.aqua;
    type = p.yellow;
    constant = p.purple;
    number = p.purple;
    string = p.green;
    escape = p.orange;
    special = p.aqua;
    variable = p.blue;
    property = p.blue;
    module = p.aqua;
    annotation = p.orange;
    operator = p.orange;
    punctuation = p.subtext0;

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
    title = p.green;

    rainbow = [
      p.red
      p.orange
      p.yellow
      p.green
      p.aqua
      p.blue
    ];

    ansi = [
      (if p.isLight then p.mantle else p.surface1)
      p.red
      p.green
      p.yellow
      p.blue
      p.purple
      p.aqua
      p.subtext0
      p.overlay2
      p.red
      p.green
      p.yellow
      p.blue
      p.purple
      p.aqua
      p.text
    ];
  };
}
