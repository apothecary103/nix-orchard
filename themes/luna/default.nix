{ ... }:

{
  name = "luna";
  description = "A near-black theme lit by four muted hues";

  # One flavor, so the ports are named `luna` rather than `luna-<something>`.
  palettes.luna = import ./palette.nix;

  defaultFlavor = "luna";
  lightFlavors = [ ];

  # Luna is built from four hues, so the accent choice is which of them leads.
  accents = {
    blue = "func";
    orange = "keyword";
    purple = "type";
    green = "string";
    amber = "signal";
    red = "error";
    yellow = "warning";
  };

  defaultAccent = "blue";

  # `base` sits below `mantle` rather than above it: luna's background is all
  # but black, so the secondary surfaces it uses for statuslines and floats are
  # the lighter ones, not darker.
  # helix has never heard of luna, so rather than settle for the engine's
  # generated theme it gets one written by hand against helix's scope list. The
  # port's palette table and its transparency handling are kept.
  ports.helix =
    { p, lib, ... }:
    data: data // import ./helix.nix { inherit p lib; };

  colours =
    { raw, ... }:
    raw
    // {
      crust = raw.black;
      mantle = raw.bg_alt;
      base = raw.bg;
      surface0 = raw.bg_soft;
      surface1 = raw.surface;
      surface2 = raw.border;
      overlay0 = raw.grey_warm;
      overlay1 = raw.comment;
      overlay2 = raw.grey;
      subtext0 = raw.grey_light;
      subtext1 = raw.silver;
      text = raw.fg;

      red = raw.error;
      orange = raw.keyword;
      yellow = raw.warning;
      lime = raw.string;
      green = raw.ok;
      aqua = raw.info;
      skye = raw.func;
      snow = raw.grey_pale;
      blue = raw.func;
      purple = raw.type;
      pink = raw.type;
      cherry = raw.cream;
    };

  roles = p: {
    cursor = p.raw.fg;
    selection = p.raw.selection;
    cursorline = p.raw.cursor_line;
    comment = p.raw.comment;

    keyword = p.raw.keyword;
    func = p.raw.func;
    macro = p.raw.keyword;
    type = p.raw.type;
    constant = p.raw.type;
    number = p.raw.keyword;
    string = p.raw.string;
    escape = p.raw.grey_light;
    special = p.raw.grey_light;
    variable = p.raw.fg;
    property = p.raw.fg;
    module = p.raw.grey_mid;
    annotation = p.raw.comment;
    operator = p.raw.grey_light;
    punctuation = p.raw.grey_mid;

    error = p.raw.error;
    warning = p.raw.warning;
    info = p.raw.info;
    hint = p.raw.hint;
    ok = p.raw.ok;

    add = p.raw.ok;
    delete = p.raw.error;
    change = p.raw.signal;

    search = p.raw.bg_plum;
    match = p.raw.signal;
    title = p.raw.silver;

    # mini.statusline's Filename section is `fg_bright` here, and StatusLineNC
    # silver — a brighter foreground than the ramp would suggest, which is the
    # whole look.
    statusBg = p.raw.bg_alt;
    statusFg = p.raw.fg_bright;
    statusDim = p.raw.silver;

    rainbow = [
      p.raw.error
      p.raw.keyword
      p.raw.warning
      p.raw.string
      p.raw.func
      p.raw.type
    ];

    # Upstream's terminal port doubles up: cyan is the blue, and slot 3 is the
    # warm UI cue rather than the yellow the diagnostics use.
    ansi = [
      p.raw.black
      p.raw.error
      p.raw.ok
      p.raw.signal
      p.raw.func
      p.raw.type
      p.raw.func
      p.raw.silver
      p.raw.grey
      p.raw.error
      p.raw.ok
      p.raw.warning
      p.raw.info
      p.raw.type
      p.raw.func
      p.raw.white
    ];
  };
}
