{ render, ... }:

let
  # catppuccin/delta. The added and removed blocks are the hue mixed into the
  # background at 20%, with the emphasised words at 35% — flat surfaces there
  # swamp the syntax highlighting underneath.
  theme =
    { p, name }:
    let
      over =
        colour: amount:
        render.mix {
          inherit colour;
          over = p.base;
        } amount;
    in
    {
      # Should match the name of the bat theme, since delta resolves syntax
      # highlighting through syntect the same way bat does.
      syntax-theme = name;

      ${if p.isLight then "light" else "dark"} = true;

      blame-palette = "${p.base} ${p.mantle} ${p.crust} ${p.surface0} ${p.surface1}";

      commit-decoration-style = "${p.overlay0} bold box ul";

      file-style = p.text;
      file-decoration-style = p.overlay0;

      hunk-header-style = "file line-number syntax";
      hunk-header-decoration-style = "${p.overlay0} box ul";
      hunk-header-file-style = "bold";
      hunk-header-line-number-style = "bold ${p.subtext0}";

      line-numbers-left-style = p.overlay0;
      line-numbers-right-style = p.overlay0;
      line-numbers-zero-style = p.overlay0;
      line-numbers-minus-style = "bold ${p.delete}";
      line-numbers-plus-style = "bold ${p.add}";

      minus-style = "syntax ${over p.delete 0.2}";
      minus-emph-style = "bold syntax ${over p.delete 0.35}";
      plus-style = "syntax ${over p.add 0.2}";
      plus-emph-style = "bold syntax ${over p.add 0.35}";

      map-styles =
        "bold purple => syntax ${over p.purple 0.35}, "
        + "bold blue => syntax ${over p.blue 0.35}, "
        + "bold cyan => syntax ${over p.skye 0.35}, "
        + "bold yellow => syntax ${over p.yellow 0.35}";
    };
in
{
  description = "delta";

  program = "delta";

  # delta highlights through syntect exactly as bat does, so its syntax-theme
  # has to be whatever name bat resolved to — built-in or generated.
  theme =
    {
      p,
      spec,
      flavor,
      accent,
      ...
    }:
    let
      integration = (spec.integrations or { }).bat or null;
      known =
        if integration == null || accent != spec.defaultAccent then null else integration.name flavor;
    in
    theme {
      inherit p;
      # Delta and bat share syntect's bundled themes, but Delta cannot load an
      # arbitrary Orchard theme file directly. ANSI is the honest generated
      # fallback: it follows the terminal palette instead of naming an asset
      # that Delta cannot resolve.
      name = if known != null then known else "ansi";
    };

  hjem = {
    when = { config, ... }: config.rum.programs.git.enable;

    config =
      { data, ... }:
      {
        rum.programs.git.settings.delta = data;
      };
  };

  home = {
    when = { config, ... }: config.programs.git.enable;

    config =
      { data, ... }:
      {
        programs.git.delta.options = data;
      };
  };
}
