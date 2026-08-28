{ lib, ... }:

{
  description = "Zed's One, dark and light";
  source = "https://github.com/zed-industries/zed/blob/main/assets/themes/one/one.json";

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

  # Only helix ships these; One Dark elsewhere is Atom's, in `themes/onedark`.
  integrations = {
    helix = {
      kind = "builtin";
      name = flavor: "zed_one${flavor}";
    };
  };

  # `mantle` sits above `base`: Zed's chrome gets lighter away from the buffer.
  colours =
    { raw, isLight, ... }:
    raw
    // {
      # Neither flavor goes below the editor, so dark borrows onedark.vim's step.
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

  # Zed's syntax map, a shade quieter than Atom's; structure stays at foreground.
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

    # Zed's diff pair is the brighter Atom one, not the muted `created`/`deleted`.
    add = p.raw.diff_plus;
    delete = p.raw.diff_minus;
    change = p.raw.warning;

    search = p.raw.search_match;
    match = p.raw.search_active;
    title = p.raw.property;

    # `status_bar.background`: outside the buffer, so it goes lighter not darker.
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
