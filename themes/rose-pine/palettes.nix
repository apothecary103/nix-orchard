# rose-pine/palette, verbatim. Rosé Pine has three greys and two highlights
# where Orchard wants nine steps, so neighbouring steps share a colour and
# `crust` on the dark flavours is the base itself; its own names ride along.
let
  flavour =
    c:
    c
    // {
      crust = if c.isDawn then c.highlightMed else c.base;
      mantle = if c.isDawn then c.overlay else c.surface;
      surface0 = c.highlightLow;
      surface1 = c.highlightMed;
      surface2 = c.highlightHigh;
      overlay0 = c.highlightHigh;
      overlay1 = c.muted;
      overlay2 = c.muted;
      subtext0 = c.subtle;
      subtext1 = c.subtle;

      red = c.love;
      orange = c.rose;
      yellow = c.gold;
      lime = c.pine;
      green = c.pine;
      aqua = c.foam;
      skye = c.foam;
      snow = c.pine;
      blue = c.foam;
      purple = c.iris;
      pink = c.iris;
      cherry = c.rose;
    };
in
{
  main = removeAttrs (flavour {
    isDawn = false;
    base = "#191724";
    surface = "#1f1d2e";
    overlay = "#26233a";
    muted = "#6e6a86";
    subtle = "#908caa";
    text = "#e0def4";
    love = "#eb6f92";
    gold = "#f6c177";
    rose = "#ebbcba";
    pine = "#31748f";
    foam = "#9ccfd8";
    iris = "#c4a7e7";
    highlightLow = "#21202e";
    highlightMed = "#403d52";
    highlightHigh = "#524f67";
  }) [ "isDawn" ];

  moon = removeAttrs (flavour {
    isDawn = false;
    base = "#232136";
    surface = "#2a273f";
    overlay = "#393552";
    muted = "#6e6a86";
    subtle = "#908caa";
    text = "#e0def4";
    love = "#eb6f92";
    gold = "#f6c177";
    rose = "#ea9a97";
    pine = "#3e8fb0";
    foam = "#9ccfd8";
    iris = "#c4a7e7";
    highlightLow = "#2a283e";
    highlightMed = "#44415a";
    highlightHigh = "#56526e";
  }) [ "isDawn" ];

  dawn = removeAttrs (flavour {
    isDawn = true;
    base = "#faf4ed";
    surface = "#fffaf3";
    overlay = "#f2e9e1";
    muted = "#9893a5";
    subtle = "#797593";
    text = "#575279";
    love = "#b4637a";
    gold = "#ea9d34";
    rose = "#d7827e";
    pine = "#286983";
    foam = "#56949f";
    iris = "#907aa9";
    highlightLow = "#f4ede8";
    highlightMed = "#dfdad9";
    highlightHigh = "#cecacd";
  }) [ "isDawn" ];
}
