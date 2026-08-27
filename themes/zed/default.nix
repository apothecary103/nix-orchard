{ lib, ... }:

{
  name = "zed";
  description = "Zed's One, dark and light";

  palettes = import ./palettes.nix;

  defaultFlavor = "dark";
  lightFlavors = [ "light" ];

  accents = lib.genAttrs [
    "red"
    "orange"
    "yellow"
    "green"
    "aqua"
    "blue"
    "purple"
  ] lib.id;

  defaultAccent = "blue";

  # helix ships both, contributed rather than derived. Nothing else does: One
  # Dark elsewhere is Atom's, which is `themes/onedark`.
  integrations = {
    helix = {
      kind = "builtin";
      name = flavor: "zed_one${flavor}";
    };
  };

  # `mantle` sits *above* `base`, as in luna: Zed's chrome gets lighter as it
  # moves outward from the buffer, so the panels and the statusline that would
  # normally be a step down are a step up instead. `crust` is the one borrowed
  # value — see palettes.nix.
  colours =
    { raw, isLight, ... }:
    raw
    // {
      crust = if isLight then raw.border else "#21252b";
      mantle = raw.surface;
      base = raw.editor_background;
      surface0 = if isLight then raw.scrollbar_track else raw.element;
      surface1 = raw.element_hover;
      surface2 = raw.background;
      overlay0 = raw.border_disabled;
      overlay1 = raw.element_active;
      overlay2 = raw.border;
      subtext0 = raw.text_placeholder;
      subtext1 = raw.text_muted;
      text = raw.text;

      red = raw.error;
      orange = raw.number;
      yellow = raw.constant;
      lime = raw.string;
      green = raw.success;
      aqua = raw.type;
      skye = raw.type;
      snow = raw.function;
      blue = raw.accent;
      purple = raw.keyword;
      pink = raw.keyword;
      cherry = raw.punctuation_special;
    };

  # Zed's own syntax map, which reads a shade quieter than Atom's: the same
  # purple keywords and green strings, but types and operators go to the one
  # cyan, constants to a sand yellow, and everything structural — variables,
  # namespaces, punctuation — is left at the editor's own foreground rather than
  # being given a hue of its own.
  roles = p: {
    selection = p.raw.border_selected;
    cursorline = p.mantle;
    comment = p.raw.comment;

    keyword = p.raw.keyword;
    func = p.raw.function;
    macro = p.raw.keyword;
    type = p.raw.type;
    constant = p.raw.constant;
    number = p.raw.number;
    string = p.raw.string;
    escape = p.raw.comment_doc;
    special = p.raw.number;
    variable = p.raw.primary;
    property = p.raw.property;
    module = p.raw.namespace;
    annotation = p.raw.accent;
    operator = p.raw.type;
    punctuation = p.raw.bracket;

    error = p.raw.error;
    warning = p.raw.warning;
    info = p.raw.accent;
    hint = p.raw.hint;
    ok = p.raw.success;

    # Zed keeps its diff colours apart from its status ones, and they are the
    # brighter Atom pair rather than the muted `created`/`deleted`.
    add = p.raw.diff_plus;
    delete = p.raw.diff_minus;
    change = p.raw.warning;

    search = p.raw.search_match;
    match = p.raw.search_active;
    title = p.raw.property;

    # `status_bar.background`, which is the workspace colour rather than a
    # darker step — the statusline sits outside the buffer, so it goes lighter.
    statusBg = p.surface2;
    statusFg = p.text;
    statusDim = p.subtext0;

    ansi = [
      p.raw.ansi_black
      p.raw.ansi_red
      p.raw.ansi_green
      p.raw.ansi_yellow
      p.raw.ansi_blue
      p.raw.ansi_magenta
      p.raw.ansi_cyan
      p.raw.ansi_white
      p.raw.ansi_bright_black
      p.raw.ansi_bright_red
      p.raw.ansi_bright_green
      p.raw.ansi_bright_yellow
      p.raw.ansi_bright_blue
      p.raw.ansi_bright_magenta
      p.raw.ansi_bright_cyan
      p.raw.ansi_bright_white
    ];
  };
}
