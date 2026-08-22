# sainnhe/gruvbox-material, verbatim. Its hues are desaturated against
# morhetz's, which is the whole point of the fork, so the two are separate
# themes here rather than flavors of one.
let
  hues = {
    red = "#ea6962";
    orange = "#e78a4e";
    yellow = "#d8a657";
    lime = "#a9b665";
    green = "#a9b665";
    aqua = "#89b482";
    skye = "#89b482";
    snow = "#7daea3";
    blue = "#7daea3";
    purple = "#d3869b";
    pink = "#d3869b";
    cherry = "#d4be98";
  };

  lightHues = {
    red = "#c14a4a";
    orange = "#c35e0a";
    yellow = "#b47109";
    lime = "#6c782e";
    green = "#6c782e";
    aqua = "#4c7a5d";
    skye = "#4c7a5d";
    snow = "#45707a";
    blue = "#45707a";
    purple = "#945e80";
    pink = "#945e80";
    cherry = "#654735";
  };

  dark = hues // {
    crust = "#1b1b1b";
    surface1 = "#3c3836";
    surface2 = "#45403d";
    overlay0 = "#5a524c";
    overlay1 = "#7c6f64";
    overlay2 = "#928374";
    subtext0 = "#a89984";
    subtext1 = "#d4be98";
    text = "#ddc7a1";
  };

  light = lightHues // {
    crust = "#eee0b7";
    surface1 = "#f2e5bc";
    surface2 = "#ebdbb2";
    overlay0 = "#d5c4a1";
    overlay1 = "#a89984";
    overlay2 = "#928374";
    subtext0 = "#7c6f64";
    subtext1 = "#654735";
    text = "#4f3829";
  };
in
{
  dark = dark // {
    base = "#282828";
    mantle = "#1d2021";
    surface0 = "#32302f";
  };

  dark-hard = dark // {
    base = "#1d2021";
    mantle = "#1b1b1b";
    crust = "#141617";
    surface0 = "#282828";
  };

  dark-soft = dark // {
    base = "#32302f";
    mantle = "#282828";
    crust = "#1d2021";
    surface0 = "#3c3836";
  };

  light = light // {
    base = "#fbf1c7";
    mantle = "#f2e5bc";
    surface0 = "#f3eac7";
  };

  light-hard = light // {
    base = "#f9f5d7";
    mantle = "#f2e5bc";
    crust = "#ebdbb2";
    surface0 = "#f3edca";
  };

  light-soft = light // {
    base = "#f2e5bc";
    mantle = "#ebdbb2";
    crust = "#d5c4a1";
    surface0 = "#eee0b7";
  };
}
