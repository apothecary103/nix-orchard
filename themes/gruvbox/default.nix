{ lib, ... }:

{
  name = "gruvbox";
  description = "Retro groove, warm and high contrast";

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

  defaultAccent = "aqua";

  # The contrast variants are only a background, so the programs that paint no
  # background — bat — collapse them, and the ones that do keep them apart.
  # btop's `gruvbox_dark` is the hard contrast and its `_v2` the medium one,
  # which is the opposite of what the names suggest.
  integrations = {
    helix = {
      kind = "builtin";
      name =
        flavor:
        {
          dark = "gruvbox";
          dark-hard = "gruvbox_dark_hard";
          dark-soft = "gruvbox_dark_soft";
          light = "gruvbox_light";
          light-hard = "gruvbox_light_hard";
          light-soft = "gruvbox_light_soft";
        }
        .${flavor};
    };

    bat = {
      kind = "builtin";
      name = flavor: if lib.hasPrefix "light" flavor then "gruvbox-light" else "gruvbox-dark";
    };

    btop = {
      kind = "builtin";
      name =
        flavor:
        {
          dark = "gruvbox_dark_v2";
          dark-hard = "gruvbox_dark";
          dark-soft = "gruvbox_dark_v2";
          light = "gruvbox_light";
          light-hard = "gruvbox_light";
          light-soft = "gruvbox_light";
        }
        .${flavor};
    };

    # micro ships only the dark one, and `-tc` is its truecolor build.
    micro = {
      kind = "builtin";
      name = flavor: if lib.hasPrefix "light" flavor then null else "gruvbox-tc";
    };

    # vivid names all six exactly as orchard does.
    vivid = {
      kind = "builtin";
      name = flavor: "gruvbox-${flavor}";
    };

    zellij = {
      kind = "builtin";
      name = flavor: if lib.hasPrefix "light" flavor then "gruvbox-light" else "gruvbox-dark";
    };
  };

  colours = { raw, ... }: raw;

  # gruvbox.vim's own highlight groups: functions and headings are green-bold,
  # types yellow, keywords red, strings green, constants purple, and the whole
  # scheme leans on orange for anything the eye should catch second.
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
    special = p.orange;
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
    change = p.aqua;

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

    # gruvbox's terminal mapping: the neutral hues take the normal slots and the
    # bright ones the bright slots, which the light flavors invert.
    ansi =
      let
        neutral = {
          red = if p.isLight then "#9d0006" else "#cc241d";
          green = if p.isLight then "#79740e" else "#98971a";
          yellow = if p.isLight then "#b57614" else "#d79921";
          blue = if p.isLight then "#076678" else "#458588";
          purple = if p.isLight then "#8f3f71" else "#b16286";
          aqua = if p.isLight then "#427b58" else "#689d6a";
        };
        bright = {
          red = if p.isLight then "#cc241d" else "#fb4934";
          green = if p.isLight then "#98971a" else "#b8bb26";
          yellow = if p.isLight then "#d79921" else "#fabd2f";
          blue = if p.isLight then "#458588" else "#83a598";
          purple = if p.isLight then "#b16286" else "#d3869b";
          aqua = if p.isLight then "#689d6a" else "#8ec07c";
        };
      in
      [
        (if p.isLight then "#fbf1c7" else "#282828")
        neutral.red
        neutral.green
        neutral.yellow
        neutral.blue
        neutral.purple
        neutral.aqua
        (if p.isLight then "#7c6f64" else "#a89984")
        (if p.isLight then "#928374" else "#928374")
        bright.red
        bright.green
        bright.yellow
        bright.blue
        bright.purple
        bright.aqua
        (if p.isLight then "#3c3836" else "#ebdbb2")
      ];
  };
}
