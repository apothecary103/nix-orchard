{ lib, render }:

let
  # bat resolves themes by name from its binary cache, so the tmTheme is compiled in.
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

      # `cache` must precede the globals since 0.26, and --blank would empty syntaxes too.
      HOME=$(mktemp -d) BAT_CONFIG_PATH=/dev/null bat cache --build \
        --source="$(dirname "$themes")" --target=$out
    '';
in
{
  description = "bat";

  program = "bat";

  # bat paints no background, so gruvbox's three contrasts collapse to one entry.
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
