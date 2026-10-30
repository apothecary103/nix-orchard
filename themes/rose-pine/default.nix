{ lib, ... }:

{
  description = "All natural pine, faux fur and a bit of soho vibes";
  source = "https://github.com/rose-pine/palette";

  palettes = import ./palettes.nix;

  defaultFlavor = "main";
  lightFlavors = [ "dawn" ];

  # Rosé Pine's own six names; each is also a palette entry.
  accents = lib.genAttrs [
    "love"
    "gold"
    "rose"
    "pine"
    "foam"
    "iris"
  ] lib.id;

  defaultAccent = "rose";

  integrations = {
    helix = {
      kind = "builtin";
      name = flavor: if flavor == "main" then "rose_pine" else "rose_pine_${flavor}";
    };
    vivid = {
      kind = "builtin";
      name = flavor: if flavor == "main" then "rose-pine" else "rose-pine-${flavor}";
    };
  };

  colours = { raw, ... }: raw;

  # rose-pine/neovim's highlight groups.
  roles = p: {
    comment = p.muted;

    keyword = p.pine;
    func = p.rose;
    macro = p.iris;
    type = p.foam;
    constant = p.gold;
    number = p.gold;
    string = p.gold;
    escape = p.pine;
    special = p.foam;
    variable = p.text;
    property = p.foam;
    module = p.iris;
    annotation = p.iris;
    operator = p.subtle;
    punctuation = p.subtle;

    error = p.love;
    warning = p.gold;
    info = p.foam;
    hint = p.iris;
    ok = p.pine;

    add = p.foam;
    delete = p.love;
    change = p.rose;

    selection = p.highlightMed;
    cursorline = p.highlightLow;
    search = p.gold;
    match = p.rose;
    title = p.foam;

    statusBg = p.surface;
    statusFg = p.subtle;
    statusInactive = p.muted;

    rainbow = [
      p.love
      p.gold
      p.rose
      p.pine
      p.foam
      p.iris
    ];

    # rose-pine/foot and friends: pine for green, foam for blue, rose for cyan.
    ansi = [
      p.overlay
      p.love
      p.pine
      p.gold
      p.foam
      p.iris
      p.rose
      p.text
      p.muted
      p.love
      p.pine
      p.gold
      p.foam
      p.iris
      p.rose
      p.text
    ];
  };
}
