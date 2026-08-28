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
          over = p.surface.background;
        } amount;
    in
    {
      # Should match the name of the bat theme, since delta resolves syntax
      # highlighting through syntect the same way bat does.
      syntax-theme = name;

      ${if p.isLight then "light" else "dark"} = true;

      blame-palette = "${p.surface.background} ${p.surface.panel} ${p.surface.shadow} ${p.surface.neutral0} ${p.surface.neutral1}";

      commit-decoration-style = "${p.surface.neutral3} bold box ul";

      file-style = p.surface.text;
      file-decoration-style = p.surface.neutral3;

      hunk-header-style = "file line-number syntax";
      hunk-header-decoration-style = "${p.surface.neutral3} box ul";
      hunk-header-file-style = "bold";
      hunk-header-line-number-style = "bold ${p.surface.textDim}";

      line-numbers-left-style = p.surface.neutral3;
      line-numbers-right-style = p.surface.neutral3;
      line-numbers-zero-style = p.surface.neutral3;
      line-numbers-minus-style = "bold ${p.status.diffDeleted}";
      line-numbers-plus-style = "bold ${p.status.diffAdded}";

      minus-style = "syntax ${over p.status.diffDeleted 0.2}";
      minus-emph-style = "bold syntax ${over p.status.diffDeleted 0.35}";
      plus-style = "syntax ${over p.status.diffAdded 0.2}";
      plus-emph-style = "bold syntax ${over p.status.diffAdded 0.35}";

      map-styles =
        "bold purple => syntax ${over p.hue.purple 0.35}, "
        + "bold blue => syntax ${over p.hue.blue 0.35}, "
        + "bold cyan => syntax ${over p.hue.skye 0.35}, "
        + "bold yellow => syntax ${over p.hue.yellow 0.35}";
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
        programs.delta.options = data;
      };
  };
}
