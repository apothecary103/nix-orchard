# morhetz/gruvbox, verbatim. The dark flavors take the `bright` hues and the
# light ones the `faded` hues, which is what gruvbox.vim itself does.
#
# `crust` is the one value gruvbox does not ship: it stops at dark0_hard, so the
# step below it is borrowed from gruvbox-material's `bg_dim`.
let
  dark = {
    crust = "#1b1b1b";
    mantle = "#1d2021";
    surface0 = "#32302f";
    surface1 = "#3c3836";
    surface2 = "#504945";
    overlay0 = "#665c54";
    overlay1 = "#7c6f64";
    overlay2 = "#928374";
    subtext0 = "#a89984";
    subtext1 = "#bdae93";
    text = "#ebdbb2";

    red = "#fb4934";
    orange = "#fe8019";
    yellow = "#fabd2f";
    lime = "#b8bb26";
    green = "#b8bb26";
    aqua = "#8ec07c";
    skye = "#8ec07c";
    snow = "#83a598";
    blue = "#83a598";
    purple = "#d3869b";
    pink = "#d3869b";
    cherry = "#d5c4a1";
  };

  light = {
    crust = "#ebdbb2";
    mantle = "#f2e5bc";
    surface0 = "#d5c4a1";
    surface1 = "#bdae93";
    surface2 = "#a89984";
    overlay0 = "#928374";
    overlay1 = "#7c6f64";
    overlay2 = "#665c54";
    subtext0 = "#504945";
    subtext1 = "#3c3836";
    text = "#282828";

    red = "#9d0006";
    orange = "#af3a03";
    yellow = "#b57614";
    lime = "#79740e";
    green = "#79740e";
    aqua = "#427b58";
    skye = "#427b58";
    snow = "#076678";
    blue = "#076678";
    purple = "#8f3f71";
    pink = "#8f3f71";
    cherry = "#7c6f64";
  };
in
{
  dark = dark // {
    base = "#282828";
  };

  dark-hard = dark // {
    base = "#1d2021";
    mantle = "#1b1b1b";
    crust = "#141617";
  };

  dark-soft = dark // {
    base = "#32302f";
    surface0 = "#3c3836";
    mantle = "#282828";
    crust = "#1d2021";
  };

  light = light // {
    base = "#fbf1c7";
  };

  light-hard = light // {
    base = "#f9f5d7";
    mantle = "#f2e5bc";
    crust = "#ebdbb2";
  };

  light-soft = light // {
    base = "#f2e5bc";
    surface0 = "#ebdbb2";
    mantle = "#fbf1c7";
    crust = "#d5c4a1";
  };
}
