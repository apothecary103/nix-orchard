# zed-industries/zed, `assets/themes/one/one.json` — the One family Zed ships
# and maintains itself. It descends from Atom's One (see `themes/onedark`) but
# is not a copy of it: the chrome is a wholly different ramp and every hue has
# been pulled down a step, so the two sit side by side rather than one being a
# flavor of the other. The names below are Zed's own, flattened from its dotted
# keys.
#
# The one value neither flavor publishes is a surface below the editor: Zed's
# chrome gets *lighter* as it moves outward from the buffer, so One Dark's
# darkest colour is the editor background itself. `crust` therefore borrows
# `#21252b` from joshdick/onedark.vim, the ancestor whose sixteen ANSI slots
# One Dark still reproduces verbatim. One Light needs no such loan — its border
# is the deepest piece of chrome it has.
{
  dark = {
    # Chrome. `background` is the workspace, `surface` the panels and tab bar,
    # `editor_background` the buffer — and it is the darkest of the three.
    background = "#3b414d"; # also status_bar, title_bar
    surface = "#2f343e"; # also panel, tab_bar, elevated_surface, active_line
    element = "#2e343e"; # also title_bar.inactive
    element_hover = "#363c46"; # also border.variant
    element_active = "#454a56"; # also element.selected
    border = "#464b57";
    border_disabled = "#414754";
    border_selected = "#293b5b";
    border_focused = "#47679e";

    editor_background = "#282c33"; # also gutter, toolbar, active tab
    editor_foreground = "#acb2be";
    line_number = "#4e5a5f"; # also editor.invisible
    active_line_number = "#d0d4da";

    text = "#dce0e5";
    text_muted = "#a9afbc";
    text_placeholder = "#878a98"; # also text.disabled, hidden, ignored

    # Syntax.
    comment = "#5d636f";
    comment_doc = "#878e98"; # also string.escape
    primary = "#acb2be"; # editor text, punctuation, variable
    bracket = "#b2b9c6"; # punctuation.bracket, punctuation.delimiter
    namespace = "#dce0e5"; # also embedded

    keyword = "#b477cf"; # also preproc
    function = "#73ade9"; # also constructor, variant
    accent = "#74ade8"; # attribute, tag, label, text.accent
    type = "#6eb4bf"; # also enum, operator, link_uri
    constant = "#dfc184"; # also selector
    number = "#bf956a"; # also boolean, string.regex, variable.special
    string = "#a1c181"; # also text.literal
    property = "#d07277"; # also variable.parameter, title, list markers
    punctuation_special = "#b1574b";
    dark_red = "#be5046"; # the second of Zed's eight player colours

    # Status.
    error = "#d07277"; # also deleted
    warning = "#dec184"; # also modified, conflict
    success = "#a1c181"; # also created
    hint = "#788ca6";
    predictive = "#5a6a87";

    diff_plus = "#98c379";
    diff_minus = "#e06c75";

    # `search.match_background` and `search.active_match_background` at full
    # opacity — Zed lays both over the buffer at 40%.
    search_match = "#74ade8";
    search_active = "#e8af74";

    # terminal.ansi.*, which is joshdick/onedark.vim's table unchanged.
    ansi_black = "#282c34";
    ansi_red = "#e06c75";
    ansi_green = "#98c379";
    ansi_yellow = "#e5c07b";
    ansi_blue = "#61afef";
    ansi_magenta = "#c678dd";
    ansi_cyan = "#56b6c2";
    ansi_white = "#abb2bf";
    ansi_bright_black = "#636d83";
    ansi_bright_red = "#ea858b";
    ansi_bright_green = "#aad581";
    ansi_bright_yellow = "#ffd885";
    ansi_bright_blue = "#85c1ff";
    ansi_bright_magenta = "#d398eb";
    ansi_bright_cyan = "#6ed5de";
    ansi_bright_white = "#fafafa";
  };

  light = {
    background = "#dcdcdd"; # also status_bar, title_bar
    surface = "#ebebec"; # also panel, tab_bar, elevated_surface, active_line
    element = "#ebebec"; # One Light gives these the same value
    element_hover = "#dfdfe0"; # also border.variant
    element_active = "#cacaca"; # also element.selected
    border = "#c9c9ca";
    border_disabled = "#d3d3d4";
    border_selected = "#cbcdf6";
    border_focused = "#7d82e8";

    editor_background = "#fafafa"; # also gutter, toolbar, active tab
    editor_foreground = "#242529";
    scrollbar_track = "#eeeeee";
    line_number = "#b4b4bb"; # also editor.invisible
    active_line_number = "#44454b";

    text = "#242529";
    text_muted = "#58585a";
    text_placeholder = "#7e8086"; # also text.disabled, hidden, ignored

    comment = "#a2a3a7";
    comment_doc = "#7c7e86"; # also string.escape
    primary = "#242529";
    bracket = "#4d4f52";
    namespace = "#242529";

    keyword = "#a449ab"; # also preproc
    function = "#5b79e3"; # also constructor, variant
    accent = "#5c78e2"; # attribute, tag, label, text.accent
    type = "#3882b7"; # also enum, operator, link_uri
    constant = "#c18401"; # also selector
    number = "#ad6e25"; # also boolean, string.regex, variable.special
    string = "#649f57"; # also text.literal
    property = "#d3604f"; # also variable.parameter, title, list markers
    punctuation_special = "#b92b46";
    dark_red = "#984ea5"; # One Light's second player colour is a plum, not a red

    error = "#d36151"; # also deleted
    warning = "#a48819"; # also modified, conflict
    success = "#669f59"; # also created
    hint = "#7274a7";
    predictive = "#9b9ec6";

    diff_plus = "#50a14f";
    diff_minus = "#e45649";

    search_match = "#5c79e2";
    search_active = "#d0a923";

    # terminal.ansi.*. One Light spells `bright_black` `#000000`, the same as
    # `black`, which would leave dim terminal text indistinguishable from the
    # rest — slot 8 takes its `dim_black` instead.
    ansi_black = "#000000";
    ansi_red = "#de3e35";
    ansi_green = "#3f953a";
    ansi_yellow = "#d2b67c";
    ansi_blue = "#2f5af3";
    ansi_magenta = "#950095";
    ansi_cyan = "#0997b3";
    ansi_white = "#bbbbbb";
    ansi_bright_black = "#555555";
    ansi_bright_red = "#de3e35";
    ansi_bright_green = "#3f953a";
    ansi_bright_yellow = "#d2b67c";
    ansi_bright_blue = "#2f5af3";
    ansi_bright_magenta = "#a00095";
    ansi_bright_cyan = "#0bbcd6";
    ansi_bright_white = "#ffffff";
  };
}
