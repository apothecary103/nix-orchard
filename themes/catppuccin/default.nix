{ lib, ... }:

{
  name = "catppuccin";
  description = "Soothing pastel theme";

  palettes = import ./palettes.nix;

  defaultFlavor = "mocha";
  lightFlavors = [ "latte" ];

  accents = lib.genAttrs [
    "rosewater"
    "flamingo"
    "pink"
    "mauve"
    "red"
    "maroon"
    "peach"
    "yellow"
    "green"
    "teal"
    "sky"
    "sapphire"
    "blue"
    "lavender"
  ] lib.id;

  defaultAccent = "mauve";

  # Catppuccin has fourteen hues where the engine names twelve, and spells five
  # of the overlapping ones differently. Both vocabularies stay live.
  # bat, vivid and zellij all bundle every flavor; btop does not, because
  # catppuccin/btop is where its theme lives and the generated one follows it.
  integrations = {
    helix = {
      kind = "builtin";
      name = flavor: "catppuccin_${flavor}";
    };
    bat = {
      kind = "builtin";
      name = flavor: "Catppuccin ${lib.toUpper (lib.substring 0 1 flavor)}${lib.substring 1 (-1) flavor}";
    };
    vivid = {
      kind = "builtin";
      name = flavor: "catppuccin-${flavor}";
    };
    zellij = {
      kind = "builtin";
      name = flavor: "catppuccin-${flavor}";
    };
  };

  colours =
    { raw, ... }:
    raw
    // {
      orange = raw.peach;
      lime = raw.green;
      aqua = raw.teal;
      skye = raw.sky;
      snow = raw.sapphire;
      purple = raw.mauve;
      cherry = raw.flamingo;
    };

  # Catppuccin's own syntax conventions, which disagree with the engine's
  # hue-derived defaults nearly everywhere.
  roles = p: {
    # Every upstream port uses rosewater for the cursor — the terminals, the
    # editors and the jump labels alike — so it is the cursor role rather than
    # the accent.
    cursor = p.rosewater;

    comment = p.overlay2;

    keyword = p.mauve;
    func = p.blue;
    macro = p.mauve;
    type = p.yellow;
    constant = p.peach;
    number = p.peach;
    string = p.green;
    escape = p.pink;
    escapeAlt = p.maroon;
    inlineCode = p.maroon;
    special = p.sky;
    variable = p.text;
    property = p.teal;
    module = p.rosewater;
    annotation = p.yellow;
    operator = p.sky;
    punctuation = p.overlay2;

    error = p.red;
    errorMuted = p.maroon;
    warning = p.yellow;
    info = p.sky;
    hint = p.teal;
    ok = p.green;

    add = p.green;
    delete = p.red;
    change = p.blue;

    search = p.sky;
    match = p.peach;
    title = p.lavender;
    secondaryAccent = p.lavender;

    # catppuccin/helix's six heading levels, which is where the ramp shows.
    rainbow = [
      p.red
      p.peach
      p.yellow
      p.green
      p.sapphire
      p.lavender
    ];

    # Upstream's terminal port. Latte swaps the two ends of the grey ramp
    # rather than reversing the whole thing.
    ansi =
      let
        dim = if p.isLight then p.subtext1 else p.surface1;
        light = if p.isLight then p.surface2 else p.subtext1;
        dimBright = if p.isLight then p.subtext0 else p.surface2;
        lightBright = if p.isLight then p.surface1 else p.subtext0;
      in
      [
        dim
        p.red
        p.green
        p.yellow
        p.blue
        p.pink
        p.teal
        light
        dimBright
        p.red
        p.green
        p.yellow
        p.blue
        p.pink
        p.teal
        lightBright
      ];
  };
}
