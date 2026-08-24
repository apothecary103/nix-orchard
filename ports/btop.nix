{ lib, ... }:

let
  # catppuccin/btop. The point of it is the three-stop gradients: every meter
  # travels across distinct hues rather than sitting on one, which is what makes
  # btop readable at a glance.
  theme = p: {
    main_bg = p.base;
    main_fg = p.text;
    title = p.text;
    hi_fg = p.accent;
    selected_bg = p.surface1;
    selected_fg = p.accent;
    inactive_fg = p.overlay1;
    graph_text = p.cherry;
    meter_bg = p.surface1;
    proc_misc = p.cherry;

    cpu_box = p.purple;
    mem_box = p.green;
    net_box = p.red;
    proc_box = p.blue;
    div_line = p.overlay0;

    temp = [
      p.green
      p.yellow
      p.red
    ];
    cpu = [
      p.aqua
      p.snow
      p.lavender
    ];
    free = [
      p.purple
      p.lavender
      p.blue
    ];
    cached = [
      p.snow
      p.blue
      p.lavender
    ];
    available = [
      p.orange
      p.maroon
      p.red
    ];
    used = [
      p.green
      p.aqua
      p.skye
    ];
    download = [
      p.orange
      p.maroon
      p.red
    ];
    upload = [
      p.green
      p.aqua
      p.skye
    ];
    process = [
      p.snow
      p.lavender
      p.purple
    ];
  };

  render' =
    data:
    let
      flat = lib.filterAttrs (_: lib.isString) data;
      gradients = lib.filterAttrs (_: lib.isList) data;

      line = key: value: ''theme[${key}]="${value}"'';

      stops =
        key: values:
        lib.zipListsWith (suffix: value: line "${key}_${suffix}" value) [ "start" "mid" "end" ] values;
    in
    lib.concatStringsSep "\n" (
      lib.mapAttrsToList line flat ++ lib.concatLists (lib.mapAttrsToList stops gradients)
    )
    + "\n";
in
{
  description = "btop";

  program = "btop";

  # btop bundles hand-tuned themes for gruvbox, gruvbox-material, onedark and
  # adwaita, gradients and all. Not catppuccin — that one lives in
  # catppuccin/btop, which the generated theme below already follows.
  upstream = true;

  theme = { p, ... }: theme p;

  hjem =
    {
      data,
      name,
      upstream,
      ...
    }:
    {
      xdg.config.files."btop/themes/${name}.theme" = lib.mkIf (upstream == null) {
        text = render' data;
      };
    };

  home = {
    when = { config, ... }: config.programs.btop.enable;

    config =
      {
        data,
        name,
        upstream,
        ...
      }:
      {
        programs.btop = {
          settings.color_theme = lib.mkDefault name;
          themes.${name} = lib.mkIf (upstream == null) (render' data);
        };
      };
  };
}
