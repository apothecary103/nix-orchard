{ lib }:

# A theme generated from an image by matugen (Material Color Utilities): every
# Material 3 role for a dark and a light scheme, plus the eight hues orchard's
# ports need, each harmonized toward the image's source colour. The image is
# read by a derivation, so this imports from it at evaluation time.
rec {
  # Radix's step-9 hues: saturated, evenly spaced, and only starting points,
  # since matugen blends each toward the source colour.
  hues = {
    red = "#e5484d";
    orange = "#f76b15";
    yellow = "#ffc53d";
    green = "#30a46c";
    aqua = "#12a594";
    blue = "#0090ff";
    purple = "#8e4ec6";
    pink = "#d6409f";
  };

  roles = [
    "primary"
    "secondary"
    "tertiary"
  ];

  accents = roles ++ lib.attrNames hues;

  generate =
    {
      pkgs,
      image,
      type ? "scheme-tonal-spot",
      contrast ? 0,
      prefer ? "saturation",
    }:
    let
      config = pkgs.writeText "matugen.toml" ''
        [config]

        [config.custom_colors]
        ${lib.concatStringsSep "\n" (
          lib.mapAttrsToList (name: hex: ''${name} = { color = "${hex}", blend = true }'') hues
        )}

        [templates]
      '';

      json = pkgs.runCommand "matugen.json" { nativeBuildInputs = [ pkgs.matugen ]; } ''
        matugen image ${image} --config ${config} --type ${type} --contrast ${toString contrast} \
          --prefer ${prefer} --include-image-in-json false --json hex --dry-run > $out
      '';
    in
    builtins.fromJSON (builtins.readFile json);

  # The Material roles in one mode, as a flat name -> "#rrggbb" set.
  rolesOf = scheme: mode: lib.mapAttrs (_: value: value.${mode}.color) scheme.colors;

  palettes =
    scheme:
    lib.genAttrs [ "dark" "light" ] (
      mode:
      let
        m = rolesOf scheme mode;
        dark = mode == "dark";
      in
      m
      // {
        # Orchard's twelve surfaces from Material's tonal ones: base is the
        # surface, the panels step away from it (darker on dark, as Catppuccin
        # does), the containers climb towards the text, and the outlines sit
        # where Catppuccin keeps its overlays.
        crust = if dark then m.surface_container_lowest else m.surface_container_high;
        mantle = if dark then m.surface_container_low else m.surface_container;
        base = m.surface;
        surface0 = m.surface_container;
        surface1 = m.surface_container_high;
        surface2 = m.surface_container_highest;
        overlay0 = m.outline_variant;
        overlay1 = m.outline_variant;
        overlay2 = m.outline;
        subtext0 = m.on_surface_variant;
        subtext1 = m.on_surface_variant;
        text = m.on_surface;

        inherit (m)
          red
          orange
          yellow
          green
          aqua
          blue
          purple
          pink
          ;
        lime = m.green;
        skye = m.aqua;
        snow = m.blue;
        cherry = m.tertiary;
      }
    );

  theme =
    args:
    let
      scheme = generate args;
    in
    {
      name = "matugen";
      description = "Material You, from an image";
      source = "https://github.com/InioX/matugen";

      palettes = palettes scheme;
      defaultFlavor = "dark";
      lightFlavors = [ "light" ];

      accents = lib.genAttrs accents lib.id;
      defaultAccent = "primary";

      colours = { raw, ... }: raw;

      # Material's own guidance where it has one: the cursor and selection in
      # the primary role, errors in error, the status bar on a container.
      roles = p: {
        cursor = p.raw.primary;
        selection = p.raw.secondary_container;
        cursorline = p.raw.surface_container_low;
        comment = p.raw.outline;
        search = p.raw.tertiary;
        match = p.raw.primary;
        title = p.raw.primary;
        secondaryAccent = p.raw.secondary;

        error = p.raw.error;
        errorMuted = p.raw.error_container;

        statusBg = p.raw.surface_container;
        statusFg = p.raw.on_surface;
        statusInactive = p.raw.on_surface_variant;
        statusDim = p.raw.outline;
        statusModeFg = p.raw.on_primary;
        statusModeNormal = p.raw.primary;
        statusModeInsert = p.raw.tertiary;
        statusModeSelect = p.raw.secondary;
      };
    };
}
