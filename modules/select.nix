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

  # Flavors and accents differ per theme, so the option types accept the union
  # and the assertion below narrows them to the theme actually chosen. A static
  # enum could not do it: the type cannot read `config`.
  allFlavors = lib.unique (lib.concatMap palette.flavorsOf (lib.attrValues themes));
  allAccents = lib.unique (lib.concatMap palette.accentsOf (lib.attrValues themes));

  # A class binding is either the module fragment itself or that fragment
  # alongside the condition the program has to meet to be themed at all.
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

  # Where each class keeps the user's packages. A port that hangs off a program
  # module is already gated by that module's `enable`; the ones that only write
  # a file have nothing to hang off, so they look for the program instead. No
  # sense shipping a micro colorscheme to someone without micro.
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

  theme = themes.${cfg.theme};

  pick =
    kind: valid: chosen: fallback:
    if chosen == null then
      fallback
    else
      lib.throwIf (!(lib.elem chosen valid))
        "orchard: ${chosen} is not ${kind} of ${cfg.theme} — pick one of ${lib.concatStringsSep ", " valid}"
        chosen;

  flavorOf = source: pick "a flavor" (palette.flavorsOf theme) source.flavor theme.defaultFlavor;
  accentOf = source: pick "an accent" (palette.accentsOf theme) source.accent theme.defaultAccent;

  # What the program itself calls this theme, if it ships one. `upstream = false`
  # on the port forces the generated theme instead.
  upstreamFor =
    name:
    let
      known = (theme.upstream or { }).${name} or (_: null);
    in
    # Whether the port has the option at all is static; asking `cfg` would force
    # the whole port, and `themeName` is in there asking this same question.
    if (ports.${name}.upstream or false) && cfg.${name}.upstream then
      known (flavorOf cfg.${name})
    else
      null;

  paletteFor =
    source:
    palette.mkPalette theme {
      flavor = flavorOf source;
      accent = accentOf source;
    };

  # What every class binding is handed. `p` is the palette the program resolved
  # to, `name` the string it files the theme under, `theme` the active theme's
  # name, and `data` the port's colours after the theme has had its say.
  argsFor =
    name: port:
    let
      base = {
        inherit lib pkgs config;
        p = paletteFor cfg.${name};
        cfg = cfg.${name};
        name = cfg.${name}.themeName;
        theme = cfg.theme;
        flavor = flavorOf cfg.${name};
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
        default = cfg.flavor;
        defaultText = lib.literalExpression "config.orchard.flavor";
        description = "Flavor to use for this program. Spelled `flavour` too.";
      };

      accent = lib.mkOption {
        type = lib.types.nullOr (lib.types.enum allAccents);
        default = cfg.accent;
        defaultText = lib.literalExpression "config.orchard.accent";
        description = "Accent to use for this program.";
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
            known = upstreamFor name;
          in
          if known != null then known else palette.nameOf theme (flavorOf cfg.${name});
        description = "Name this program resolves the theme by.";
      };
    }
    // lib.optionalAttrs (port.upstream or false) {
      upstream = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          Prefer the theme this program ships itself, where it ships one. Those
          are hand-tuned against the program's own internals — syntax scopes,
          gradients, icon sets — but they are fixed, so the accent has no say in
          them. Turn it off to generate from the palette instead.
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
        the terminal's own background — and whatever transparency it has — shows
        through. Only the ports that can honour it carry the option.
      '';
    };

    palette = lib.mkOption {
      type = lib.types.attrs;
      readOnly = true;
      default = paletteFor cfg;
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
        inherit (t) description;
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
