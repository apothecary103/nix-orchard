{ lib, render }:

let
  # catppuccin/fish.
  theme =
    p:
    let
      c = render.noHash;
    in
    {
      fish_color_normal = c p.surface.text;
      fish_color_command = c p.syntax.function;
      fish_color_param = c p.hue.cherry;
      fish_color_keyword = c p.syntax.keyword;
      fish_color_quote = c p.syntax.string;
      fish_color_redirection = c p.hue.pink;
      fish_color_end = c p.hue.orange;
      fish_color_comment = c p.surface.neutral4;
      fish_color_error = c p.status.error;
      fish_color_gray = c p.surface.neutral3;
      fish_color_selection = "--background=${c p.surface.neutral0}";
      fish_color_search_match = "--background=${c p.surface.neutral0}";
      fish_color_option = c p.syntax.string;
      fish_color_operator = c p.hue.pink;
      fish_color_escape = c p.syntax.escapeAlt;
      fish_color_autosuggestion = c p.surface.neutral3;
      fish_color_cancel = c p.status.error;
      fish_color_cwd = c p.hue.yellow;
      fish_color_user = c p.hue.aqua;
      fish_color_host = c p.syntax.function;
      fish_color_host_remote = c p.status.success;
      fish_color_status = c p.status.error;

      fish_pager_color_progress = c p.surface.neutral3;
      fish_pager_color_prefix = c p.hue.pink;
      fish_pager_color_completion = c p.surface.text;
      fish_pager_color_description = c p.surface.neutral3;
    };

  # The file only previews: `fish_config theme choose` writes universals that win.
  emit = sep: data: lib.concatStringsSep "\n" (lib.mapAttrsToList (k: v: "${sep}${k} ${v}") data);
in
{
  description = "fish";

  theme = { p, ... }: theme p;

  hjem = {
    when = { config, ... }: config.rum.programs.fish.enable;

    config =
      { data, name, ... }:
      {
        rum.programs.fish.earlyConfigFiles.orchard = emit "set -g " data;

        xdg.config.files."fish/themes/${name}.theme".text = emit "" data;
      };
  };

  home = {
    when = { config, ... }: config.programs.fish.enable;

    config =
      { data, name, ... }:
      {
        programs.fish.interactiveShellInit = lib.mkBefore (emit "set -g " data);

        xdg.configFile."fish/themes/${name}.theme".text = emit "" data;
      };
  };
}
