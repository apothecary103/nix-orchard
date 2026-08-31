{ lib, ... }:

let
  # catppuccin/btop, whose meters travel three-stop gradients rather than one hue.
  theme = p: {
    main_bg = p.surface.background;
    main_fg = p.surface.text;
    title = p.surface.text;
    hi_fg = p.ui.accent;
    selected_bg = p.surface.neutral1;
    selected_fg = p.ui.accent;
    inactive_fg = p.surface.neutral4;
    graph_text = p.hue.cherry;
    meter_bg = p.surface.neutral1;
    proc_misc = p.hue.cherry;

    cpu_box = p.hue.purple;
    mem_box = p.hue.green;
    net_box = p.hue.red;
    proc_box = p.hue.blue;
    div_line = p.surface.neutral3;

    temp = [
      p.hue.green
      p.hue.yellow
      p.hue.red
    ];
    cpu = [
      p.hue.aqua
      p.hue.snow
      p.ui.secondaryAccent
    ];
    free = [
      p.hue.purple
      p.ui.secondaryAccent
      p.hue.blue
    ];
    cached = [
      p.hue.snow
      p.hue.blue
      p.ui.secondaryAccent
    ];
    available = [
      p.hue.orange
      p.status.errorMuted
      p.hue.red
    ];
    used = [
      p.hue.green
      p.hue.aqua
      p.hue.skye
    ];
    download = [
      p.hue.orange
      p.status.errorMuted
      p.hue.red
    ];
    upload = [
      p.hue.green
      p.hue.aqua
      p.hue.skye
    ];
    process = [
      p.hue.snow
      p.ui.secondaryAccent
      p.hue.purple
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

  # btop bundles gruvbox, gruvbox-material, onedark and adwaita, but not catppuccin.
  integration = { };

  theme = { p, ... }: theme p;

  hjem =
    {
      data,
      name,
      provider,
      upstream,
      ...
    }:
    let
      selected = if provider == null then { } else provider;
      providerFile = selected.file or (builtins.toFile "orchard-unused-btop-theme" "");
    in
    {
      xdg.config.files."btop/themes/${name}.theme" = lib.mkMerge [
        (lib.mkIf (upstream == null) { text = render' data; })
        (lib.mkIf (selected ? file) { source = providerFile; })
      ];
    };

  home = {
    when = { config, ... }: config.programs.btop.enable;

    config =
      {
        data,
        name,
        provider,
        upstream,
        ...
      }:
      let
        selected = if provider == null then { } else provider;
        providerFile = selected.file or (builtins.toFile "orchard-unused-btop-theme" "");
      in
      lib.mkMerge [
        {
          programs.btop = {
            settings.color_theme = lib.mkDefault name;
          }
          // lib.optionalAttrs (upstream == null) { themes.${name} = render' data; };
        }
        (lib.mkIf (selected ? file) {
          xdg.configFile."btop/themes/${name}.theme".source = providerFile;
        })
      ];
  };
}
