{ lib, render }:

let
  # bat only resolves a theme by name out of its binary cache, so the tmTheme
  # has to be compiled in rather than dropped into the config directory.
  cache =
    {
      pkgs,
      data,
      name,
    }:
    pkgs.runCommandLocal "bat-cache-${name}" { nativeBuildInputs = [ pkgs.bat ]; } ''
      themes=$(mktemp -d)/themes
      mkdir -p "$themes" $out
      cp ${pkgs.writeText "${name}.tmTheme" data} "$themes/${name}.tmTheme"

      # Two things bat is particular about here. `cache` has to come before the
      # global options, which stopped being interchangeable in 0.26. And there
      # is no --blank: that starts *both* sets empty, not just the theme set, so
      # the cache ends up with zero syntaxes and every file renders as plain
      # text in the default foreground. Appending to the defaults costs a
      # megabyte and is the only way to keep the 183 languages.
      HOME=$(mktemp -d) BAT_CONFIG_PATH=/dev/null bat cache --build \
        --source="$(dirname "$themes")" --target=$out
    '';
in
{
  description = "bat";

  program = "bat";

  # bat bundles all four catppuccin flavors and both gruvbox ends, as real
  # Sublime themes with the scope coverage that implies. It also paints no
  # background — checked, not assumed — so gruvbox's hard and soft contrasts are
  # indistinguishable here and one entry serves all three.
  integration = { };

  theme = { p, name, ... }: render.mkTmTheme { inherit name p; };

  hjem =
    {
      pkgs,
      data,
      name,
      upstream,
      ...
    }:
    {
      environment.sessionVariables = {
        BAT_THEME = lib.mkDefault name;
        BAT_CACHE_PATH = lib.mkIf (upstream == null) (lib.mkDefault "${cache { inherit pkgs data name; }}");
      };
    };

  home = {
    when = { config, ... }: config.programs.bat.enable;

    config =
      {
        pkgs,
        data,
        name,
        upstream,
        ...
      }:
      {
        programs.bat = {
          config.theme = lib.mkDefault name;

          themes.${name} = lib.mkIf (upstream == null) {
            src = pkgs.writeTextDir "${name}.tmTheme" data;
            file = "${name}.tmTheme";
          };
        };
      };
  };
}
