{ lib, render }:

let
  # catppuccin/delta: blocks are the hue at 20% over the background, words at 35%.
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

  # delta uses syntect as bat does, so syntax-theme is whatever bat resolved to.
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
      # delta cannot load an Orchard theme file, so ansi is the honest fallback.
      name = if known != null then known else "ansi";
    };

  hjem = {
    when = { config, ... }: config.rum.programs.git.enable;

    config =
      { data, ... }:
      {
        rum.programs.git.settings.delta = lib.mapAttrsRecursive (_: lib.mkDefault) data;
      };
  };

  home = {
    when = { config, ... }: config.programs.git.enable;

    config =
      { data, ... }:
      {
        programs.delta.options = lib.mapAttrsRecursive (_: lib.mkDefault) data;
      };
  };
}
