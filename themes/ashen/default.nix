{ lib, render }:

{
  description = "Embers on charcoal";
  source = "https://codeberg.org/ficd/ashen.nvim";

  # One flavor, and a dark one: ashen has no light counterpart.
  palettes.ashen = import ./palettes.nix;

  defaultFlavor = "ashen";
  lightFlavors = [ ];

  accents = {
    blaze = "orange_blaze";
    glow = "orange_glow";
    golden = "orange_golden";
    smolder = "orange_smolder";
    ember = "red_ember";
    flame = "red_flame";
    glowing = "red_glowing";
    teal = "blue";
    brown = "brown";
  };

  defaultAccent = "blaze";

  # Ashen's own ports are reproduced below: this monochrome does not derive well.
  integrations.helix = {
    kind = "builtin";
    name = _: "ashen";
  };

  ports = {
    yazi =
      { p, lib, ... }:
      data: import ./yazi.nix { inherit p lib data; };
    fzf = { p, ... }: _: import ./fzf.nix { inherit p; };
    fish = { p, ... }: _: import ./fish.nix { inherit p; };
  };

  # Ashen has no green and one teal, so the whole cool end points at that teal.
  colours =
    { raw, ... }:
    raw
    // {
      # Upstream stops at its background, so the step below is mixed down.
      crust = render.mix {
        colour = raw.background;
        over = "#000000";
      } 0.65;
      mantle = raw.g_12;
      base = raw.background;
      surface0 = raw.g_11;
      surface1 = raw.g_10;
      surface2 = raw.g_9;
      overlay0 = raw.g_8;
      overlay1 = raw.g_7;
      overlay2 = raw.g_6;
      subtext0 = raw.g_5;
      subtext1 = raw.g_4;
      text = raw.g_3;

      red = raw.red_glowing;
      orange = raw.orange_glow;
      yellow = raw.orange_golden;
      lime = raw.green;
      green = raw.green;
      aqua = raw.blue;
      skye = raw.blue;
      snow = raw.g_4;
      blue = raw.blue;
      purple = raw.brown;
      pink = raw.orange_blaze;
      cherry = raw.g_2;
    };

  # ashen.toml scope for scope: the accents go to operators, not identifiers.
  roles = p: {
    cursor = p.raw.g_3;
    selection = p.raw.brown_dark;
    cursorline = p.raw.cursorline;
    comment = p.raw.g_6;

    keyword = p.raw.red_ember;
    func = p.raw.g_3;
    macro = p.raw.red_ember;
    type = p.raw.blue;
    constant = p.raw.orange_blaze;
    number = p.raw.blue;
    string = p.raw.red_glowing;
    escape = p.raw.g_2;
    special = p.raw.orange_smolder;
    variable = p.raw.g_3;
    property = p.raw.g_2;
    module = p.raw.orange_glow;
    annotation = p.raw.g_4;
    operator = p.raw.orange_glow;
    punctuation = p.raw.g_2;

    error = p.raw.red_flame;
    warning = p.raw.orange_golden;
    info = p.raw.blue;
    hint = p.raw.g_5;
    ok = p.raw.green;

    add = p.raw.green;
    delete = p.raw.red_ember;
    change = p.raw.brown;

    search = p.raw.orange_blaze;
    match = p.raw.orange_golden;
    title = p.raw.red_glowing;

    statusBg = p.raw.g_9;
    statusFg = p.raw.g_3;
    statusDim = p.raw.g_5;

    rainbow = [
      p.raw.red_glowing
      p.raw.orange_glow
      p.raw.orange_golden
      p.raw.orange_smolder
      p.raw.blue
      p.raw.red_ember
    ];

    # Ashen's own mapping: greys take magenta and cyan rather than inventing hues.
    ansi = [
      p.raw.background
      p.raw.red_ember
      p.raw.orange_glow
      p.raw.orange_smolder
      p.raw.blue
      p.raw.g_4
      p.raw.g_3
      p.raw.g_2
      p.raw.g_5
      p.raw.red_ember
      p.raw.orange_glow
      p.raw.orange_smolder
      p.raw.blue
      p.raw.g_4
      p.raw.g_3
      p.raw.g_2
    ];
  };
}
