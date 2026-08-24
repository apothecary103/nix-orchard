{ lib, render }:

let
  # catppuccin/fish. Commands are blue, parameters the soft warm tint, keywords
  # the keyword hue and everything quoted green; the pager follows the same
  # grammar one step dimmer.
  theme =
    p:
    let
      c = render.noHash;
    in
    {
      fish_color_normal = c p.text;
      fish_color_command = c p.func;
      fish_color_param = c p.cherry;
      fish_color_keyword = c p.keyword;
      fish_color_quote = c p.string;
      fish_color_redirection = c p.pink;
      fish_color_end = c p.orange;
      fish_color_comment = c p.overlay1;
      fish_color_error = c p.error;
      fish_color_gray = c p.overlay0;
      fish_color_selection = "--background=${c p.surface0}";
      fish_color_search_match = "--background=${c p.surface0}";
      fish_color_option = c p.string;
      fish_color_operator = c p.pink;
      fish_color_escape = c p.maroon;
      fish_color_autosuggestion = c p.overlay0;
      fish_color_cancel = c p.error;
      fish_color_cwd = c p.yellow;
      fish_color_user = c p.aqua;
      fish_color_host = c p.func;
      fish_color_host_remote = c p.ok;
      fish_color_status = c p.error;

      fish_pager_color_progress = c p.overlay0;
      fish_pager_color_prefix = c p.pink;
      fish_pager_color_completion = c p.text;
      fish_pager_color_description = c p.overlay0;
    };

  # A theme file alone would only take effect once `fish_config theme choose`
  # ran, and that writes universal variables which then shadow everything set
  # from a config file. The file is for previewing; the globals are what
  # actually apply.
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
