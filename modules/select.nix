{
  lib,
  class,
  themes,
  ports,
  palette,
}:

let
  available = lib.filterAttrs (_: port: port ? ${class}) ports;

  names = lib.attrNames themes;

  # Types take the union because a type cannot read `config`; assertions narrow it.
  allFlavors = lib.unique (lib.concatMap palette.flavorsOf (lib.attrValues themes));
  allAccents = lib.unique (lib.concatMap palette.accentsOf (lib.attrValues themes));

  binding =
    port:
    let
      given = port.${class};
    in
    if lib.isFunction given then
      {
        when = _: true;
        config = given;
      }
    else
      { when = _: true; } // given;

  moduleClass = {
    hjem = "hjem";
    home = "homeManager";
    nixos = "nixos";
  };
in

{ config, pkgs, ... }:

let
  cfg = config.orchard;

  # Ports with no program module to hang off look for the package instead.
  installedIn = {
    hjem = config.packages or [ ];
    home = config.home.packages or [ ];
    nixos = [ ];
  };

  installed =
    port:
    let
      wanted = port.program or null;
    in
    wanted == null || lib.any (drv: (lib.getName drv) == wanted) installedIn.${class};

  globalTheme = themes.${cfg.theme};

  pick =
    themeName: kind: valid: chosen: fallback:
    if chosen == null then
      fallback
    else
      lib.throwIf (!(lib.elem chosen valid))
        "orchard: ${chosen} is not ${kind} of ${themeName}. Choose one of ${lib.concatStringsSep ", " valid}"
        chosen;

  globalFlavor =
    pick cfg.theme "a flavor" (palette.flavorsOf globalTheme) cfg.flavor
      globalTheme.defaultFlavor;
  globalAccent =
    pick cfg.theme "an accent" (palette.accentsOf globalTheme) cfg.accent
      globalTheme.defaultAccent;

  themeNameOf = source: if source.theme == null then cfg.theme else source.theme;

  themeOf = source: themes.${themeNameOf source};

  flavorOf =
    source:
    let
      themeName = themeNameOf source;
      theme = themes.${themeName};
      chosen =
        if source.flavor != null then
          source.flavor
        else if source.theme == null then
          cfg.flavor
        else
          null;
    in
    pick themeName "a flavor" (palette.flavorsOf theme) chosen theme.defaultFlavor;

  accentOf =
    source:
    let
      themeName = themeNameOf source;
      theme = themes.${themeName};
      chosen =
        if source.accent != null then
          source.accent
        else if source.theme == null then
          cfg.accent
        else
          null;
    in
    pick themeName "an accent" (palette.accentsOf theme) chosen theme.defaultAccent;

  # Auto takes a built-in only when it can honour the accent and transparency.
  integrationFor =
    name:
    if !(ports.${name} ? integration) then
      null
    else
      let
        theme = themeOf cfg.${name};
        declared = (theme.integrations or { }).${name} or null;
        available =
          if declared == null then
            null
          else
            let
              upstreamName = declared.name (flavorOf cfg.${name});
            in
            if upstreamName == null then null else declared // { name = upstreamName; };
        capabilities = {
          accent = false;
          transparent = false;
        }
        // (ports.${name}.integration.upstream or { });
        supported =
          # A global accent guides generated ports; it should not disqualify a
          # hand-tuned upstream theme. Only a per-port accent is a requirement.
          (capabilities.accent || cfg.${name}.accent == null || accentOf cfg.${name} == theme.defaultAccent)
          && (capabilities.transparent || !(cfg.${name}.transparent or false));
        requested = cfg.${name}.source;
      in
      if requested == "generated" then
        null
      else if requested == "upstream" then
        lib.throwIf (available == null)
          "orchard: ${themeNameOf cfg.${name}} has no upstream ${name} integration"
          (
            lib.throwIf (!supported)
              "orchard: the upstream ${name} integration cannot honour the requested accent or transparency; use source = \"auto\" or \"generated\""
              available
          )
      else if available != null && supported then
        available
      else
        null;

  upstreamFor =
    name:
    let
      integration = integrationFor name;
    in
    if integration == null then null else integration.name;

  paletteFor =
    source:
    let
      theme = themeOf source;
    in
    palette.mkPalette theme {
      flavor = flavorOf source;
      accent = accentOf source;
    };

  # What every class binding is handed; `data` is the port's colours after the theme.
  argsFor =
    name: port:
    let
      theme = themeOf cfg.${name};
      base = {
        inherit lib pkgs config;
        p = paletteFor cfg.${name};
        cfg = cfg.${name};
        name = cfg.${name}.themeName;
        theme = themeNameOf cfg.${name};
        flavor = flavorOf cfg.${name};
        accent = accentOf cfg.${name};
        spec = theme;
        upstream = upstreamFor name;
        port = name;
      };

      tune = (theme.ports or { }).${name} or (_: data: data);
    in
    base // lib.optionalAttrs (port ? theme) { data = tune base (port.theme base); };

  extraOptions =
    name: port:
    let
      given = port.options or { };
    in
    if lib.isFunction given then
      given {
        inherit lib;
        port = name;
      }
    else
      given;

  portOptions = lib.mapAttrs (
    name: port:
    {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = cfg.enable && cfg.autoEnable && installed port;
        defaultText = lib.literalExpression "config.orchard.enable && config.orchard.autoEnable, if the program is installed";
        description = "Whether to theme ${port.description or name}.";
      };

      flavor = lib.mkOption {
        type = lib.types.nullOr (lib.types.enum allFlavors);
        default = null;
        defaultText = lib.literalExpression "config.orchard.flavor, or the per-program theme's default";
        description = ''
          Flavor to use for this program. Spelled `flavour` too. Null inherits
          the global flavor while inheriting the global theme, or takes a
          per-program theme's own default.
        '';
      };

      accent = lib.mkOption {
        type = lib.types.nullOr (lib.types.enum allAccents);
        default = null;
        defaultText = lib.literalExpression "config.orchard.accent, or the per-program theme's default";
        description = ''
          Accent to use for this program. Null inherits the global accent while
          inheriting the global theme, or takes a per-program theme's own
          default.
        '';
      };

      theme = lib.mkOption {
        type = lib.types.nullOr (lib.types.enum names);
        default = null;
        defaultText = lib.literalExpression "config.orchard.theme";
        description = "Theme to use for this program. Null inherits the global theme.";
      };

      palette = lib.mkOption {
        type = lib.types.attrs;
        readOnly = true;
        default = paletteFor cfg.${name};
        defaultText = lib.literalExpression "the palette this program resolved to";
        description = "The colours this program was themed with.";
      };

      themeName = lib.mkOption {
        type = lib.types.str;
        readOnly = true;
        default =
          let
            theme = themeOf cfg.${name};
            known = upstreamFor name;
            baseName = if known != null then known else palette.nameOf theme (flavorOf cfg.${name});
            resolveName = port.resolveName or ({ name, ... }: name);
          in
          resolveName {
            name = baseName;
            upstream = known;
            cfg = cfg.${name};
          };
        description = "Name this program resolves the theme by.";
      };
    }
    // lib.optionalAttrs (port ? integration) {
      source = lib.mkOption {
        type = lib.types.enum [
          "auto"
          "upstream"
          "generated"
        ];
        default = "auto";
        description = ''
          Where this program's theme comes from. Auto prefers an upstream theme
          when it exists and can honour the requested accent and transparency,
          then falls back to Orchard's generated theme. Upstream requires a
          compatible built-in integration; generated always uses the palette.
        '';
      };

      resolvedSource = lib.mkOption {
        type = lib.types.str;
        readOnly = true;
        default =
          let
            integration = integrationFor name;
          in
          if integration == null then "generated" else integration.kind;
        description = ''
          Source actually selected for this program: generated, builtin, or an
          official theme integration.
        '';
      };
    }
    // lib.optionalAttrs (port.transparency or false) {
      transparent = lib.mkOption {
        type = lib.types.bool;
        default = cfg.transparent;
        defaultText = lib.literalExpression "config.orchard.transparent";
        description = "Drop this program's background so the terminal shows through.";
      };
    }
    // extraOptions name port
  ) available;
in

{
  _class = moduleClass.${class};

  imports = [
    (lib.mkAliasOptionModule [ "orchard" "flavour" ] [ "orchard" "flavor" ])
  ]
  ++ lib.mapAttrsToList (
    name: _: lib.mkAliasOptionModule [ "orchard" name "flavour" ] [ "orchard" name "flavor" ]
  ) available;

  options.orchard = {
    enable = lib.mkEnableOption "orchard";

    theme = lib.mkOption {
      type = lib.types.enum names;
      default = "catppuccin";
      description = "Which theme to wear. One of ${lib.concatStringsSep ", " names}.";
    };

    autoEnable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Theme every supported program that this configuration also enables.
        Turn it off to opt in per program instead.
      '';
    };

    flavor = lib.mkOption {
      type = lib.types.nullOr (lib.types.enum allFlavors);
      default = null;
      defaultText = lib.literalExpression "the theme's own default flavor";
      description = ''
        Variant to theme with, from the chosen theme's own list. Spelled
        `flavour` too. Null takes whatever that theme calls its default.
      '';
    };

    accent = lib.mkOption {
      type = lib.types.nullOr (lib.types.enum allAccents);
      default = null;
      defaultText = lib.literalExpression "the theme's own default accent";
      description = ''
        Hue used for cursors, prompts, selected tabs and other focal UI, from
        the chosen theme's own list. Null takes that theme's default.
      '';
    };

    transparent = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Leave the background unpainted wherever a program can be told to, so
        the terminal's own background shows through, along with whatever
        transparency it has. Only the ports that can honour it carry the option.
      '';
    };

    palette = lib.mkOption {
      type = lib.types.attrs;
      readOnly = true;
      default = palette.mkPalette globalTheme {
        flavor = globalFlavor;
        accent = globalAccent;
      };
      defaultText = lib.literalExpression "every colour and role of the chosen flavor";
      description = ''
        The whole palette, for configs no port here covers. Also available as
        the `orchardPalette` module argument.
      '';
    };

    catalogue = lib.mkOption {
      type = lib.types.attrs;
      readOnly = true;
      default = lib.mapAttrs (_: t: {
        inherit (t) description source;
        flavors = palette.flavorsOf t;
        accents = palette.accentsOf t;
      }) themes;
      description = "Every theme on offer, with the flavors and accents it takes.";
    };
  }
  // portOptions;

  config = lib.mkMerge (
    [ { _module.args.orchardPalette = cfg.palette; } ]
    ++ lib.mapAttrsToList (
      name: port:
      let
        bound = binding port;
        args = argsFor name port;
      in
      lib.mkIf (cfg.${name}.enable && bound.when args) (bound.config args)
    ) available
  );
}
