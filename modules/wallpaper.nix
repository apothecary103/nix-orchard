{
  lib,
  class,
  ports,
  render,
}:

{
  config,
  options,
  pkgs,
  ...
}:

let
  cfg = config.orchard.wallpaper;
  p = config.orchard.palette;

  # Read with fallbacks: orchard's own checks evaluate this against stubs.
  dirs =
    let
      home = config.directory or config.home.homeDirectory or "/homeless-shelter";
    in
    if class == "hjem" then
      {
        state = config.xdg.state.directory or "${home}/.local/state";
        config = config.xdg.config.directory or "${home}/.config";
      }
    else
      {
        state = config.xdg.stateHome or "${home}/.local/state";
        config = config.xdg.configHome or "${home}/.config";
      };

  # Every colour of the palette by its dotted name, as orchard-wallpaper
  # spells them: surface.background, statusBar.mode.normal, terminal.ansi.3.
  groups = [
    "surface"
    "hue"
    "syntax"
    "ui"
    "status"
    "statusBar"
  ];
  flatten =
    prefix: value:
    if lib.isAttrs value then
      lib.concatLists (lib.mapAttrsToList (k: v: flatten "${prefix}.${k}" v) value)
    else
      [ (lib.nameValuePair prefix value) ];
  colours = lib.listToAttrs (
    lib.concatMap (g: flatten g p.${g}) groups
    ++ lib.imap0 (i: c: lib.nameValuePair "terminal.ansi.${toString i}" c) p.terminal.ansi
  );

  # A template filled from the configured theme: what the files hold until
  # there is a wallpaper to read, and what sway's own config starts from.
  renderStatic =
    name: template:
    let
      keys = lib.attrNames colours;
      text = lib.replaceStrings (map (k: "{{${k}}}") keys ++ map (k: "{{${k}|bare}}") keys) (
        map (k: colours.${k}) keys ++ map (k: render.noHash colours.${k}) keys
      ) template;
    in
    lib.throwIf (lib.hasInfix "{{" text)
      "orchard.wallpaper.targets.${name}: a template names a colour the palette does not have (tokens are written {{group.name}} or {{group.name|bare}}, without spaces)"
      text;

  # The palette with every colour replaced by its own token, so a port's
  # theme function writes a template instead of a theme. `#{{k|bare}}` is a
  # colour to the port and survives its noHash either way.
  placeholders =
    lib.mapAttrsRecursive (path: _: "#{{${lib.concatStringsSep "." path}|bare}}") (
      lib.getAttrs groups p
    )
    // {
      terminal.ansi = lib.genList (i: "#{{terminal.ansi.${toString i}|bare}}") 16;
      isLight = cfg.flavor == "light";
    };

  bar = id: role: "bar ${id} colors ${role}";

  swayTemplate = ''
    # Window and bar colours from the wallpaper, by orchard-wallpaper.
    client.focused          {{ui.accent}} {{ui.accent}} {{surface.background}} {{ui.accent}} {{ui.accent}}
    client.focused_inactive {{surface.neutral0}} {{surface.neutral0}} {{surface.textDim}} {{surface.neutral0}} {{surface.neutral0}}
    client.focused_tab_title {{surface.neutral1}} {{surface.neutral1}} {{surface.text}}
    client.unfocused        {{surface.neutral0}} {{surface.neutral0}} {{surface.textDim}} {{surface.neutral0}} {{surface.neutral0}}
    client.urgent           {{status.error}} {{status.error}} {{surface.background}} {{status.error}} {{status.error}}
    client.placeholder      {{surface.panel}} {{surface.panel}} {{surface.textDim}} {{surface.panel}} {{surface.panel}}
    client.background       {{surface.background}}
  ''
  + lib.concatMapStrings (id: ''
    ${bar id "background"} {{surface.panel}}
    ${bar id "statusline"} {{surface.text}}
    ${bar id "separator"} {{surface.neutral3}}
    ${bar id "focused_workspace"} {{ui.accent}} {{ui.accent}} {{surface.background}}
    ${bar id "active_workspace"} {{surface.neutral1}} {{surface.neutral1}} {{surface.text}}
    ${bar id "inactive_workspace"} {{surface.panel}} {{surface.panel}} {{surface.textDim}}
    ${bar id "urgent_workspace"} {{status.error}} {{status.error}} {{surface.background}}
    ${bar id "binding_mode"} {{status.warning}} {{status.warning}} {{surface.background}}
  '') cfg.sway.bars;

  # fuzzel's own port, filled with tokens: one description of its colours.
  fuzzelTemplate = lib.generators.toINI { } {
    colors = (ports.fuzzel.theme { p = placeholders; }) // cfg.fuzzel.colours;
  };

  swaynagTemplate =
    let
      kind = border: ''
        background={{surface.panel|bare}}
        text={{surface.text|bare}}
        border={{${border}|bare}}
        border-bottom={{${border}|bare}}
        button-background={{surface.neutral0|bare}}
        button-text={{surface.text|bare}}
        details-background={{surface.background|bare}}
      '';
    in
    ''
      [warning]
      ${kind "status.warning"}
      [error]
      ${kind "status.error"}
    '';

  configFile = pkgs.writeText "orchard-wallpaper.json" (
    builtins.toJSON {
      inherit (cfg) flavor tint;
      accent = if cfg.accent == "theme" then p.ui.accent else cfg.accent;
      fallbackAccent = p.ui.accent;
      stateDir = cfg.stateDirectory;
      targets = lib.mapAttrsToList (name: t: {
        inherit name;
        inherit (t) path sway reload;
        template = pkgs.writeText "orchard-wallpaper-${name}" t.template;
        fallback = pkgs.writeText "orchard-wallpaper-${name}-fallback" t.fallback;
      }) cfg.targets;
    }
  );

  command = "${lib.getExe cfg.package} watch --config ${configFile}";

  targetType = lib.types.submodule (
    { name, config, ... }:
    {
      options = {
        template = lib.mkOption {
          type = lib.types.lines;
          description = ''
            The file to write, with colours as `{{group.name}}` (`#rrggbb`)
            or `{{group.name|bare}}` (`rrggbb`), named as in
            `config.orchard.palette`: `surface.background`, `ui.accent`,
            `statusBar.mode.normal`, `terminal.ansi.4`.
          '';
        };

        path = lib.mkOption {
          type = lib.types.str;
          default = "${cfg.stateDirectory}/${name}";
          defaultText = lib.literalExpression ''"''${config.orchard.wallpaper.stateDirectory}/<name>"'';
          description = "Where the filled-in file is kept.";
        };

        sway = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = ''
            Also run the file's lines as sway commands whenever it changes, so
            sway follows without a reload. Every line must then be a command
            sway takes both at runtime and in its config.
          '';
        };

        reload = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          example = [
            "makoctl"
            "reload"
          ];
          description = "Command to run after the file changes, if any.";
        };

        fallback = lib.mkOption {
          type = lib.types.str;
          readOnly = true;
          default = renderStatic name config.template;
          defaultText = lib.literalExpression "the template filled from config.orchard.palette";
          description = ''
            The template filled from the configured theme. orchard-wallpaper
            writes it when no wallpaper is showing; include it ahead of the
            live file so a program reads sensible colours before the service
            first runs.
          '';
        };
      };
    }
  );
in
{
  options.orchard.wallpaper = {
    enable = lib.mkEnableOption ''
      colours from the wallpaper sway shows. A user service reads the image,
      mode and fallback colour each running swaybg was given, lays the image
      out on every output the way swaybg does, and derives a palette from
      what is actually visible: greys that lean toward the wallpaper at each
      lightness, its own colour as the accent, and twelve hues that bend
      toward it while staying recognisable, all checked for contrast. The
      files in `targets` are rewritten whenever the wallpaper changes
    '';

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.callPackage ../wallpaper/package.nix { };
      defaultText = lib.literalExpression "orchard's orchard-wallpaper";
      description = "The orchard-wallpaper package.";
    };

    flavor = lib.mkOption {
      type = lib.types.enum [
        "auto"
        "dark"
        "light"
      ];
      default = if p.isLight then "light" else "dark";
      defaultText = lib.literalExpression ''if config.orchard.palette.isLight then "light" else "dark"'';
      description = ''
        Dark or light scheme. Auto picks light only for a plainly light
        wallpaper without much shadow in it.
      '';
    };

    accent = lib.mkOption {
      type = lib.types.either (lib.types.enum [
        "auto"
        "theme"
      ]) (lib.types.strMatching "#[0-9a-fA-F]{6}");
      default = "auto";
      description = ''
        `auto` takes the wallpaper's own colour (the configured theme's
        accent when it has none), `theme` always keeps the configured theme's
        accent, or give a colour.
      '';
    };

    tint = lib.mkOption {
      type = lib.types.numbers.between 0 1;
      default = 1.0;
      description = "How far the greys may lean toward the wallpaper; 0 keeps them pure grey.";
    };

    stateDirectory = lib.mkOption {
      type = lib.types.str;
      default = "${dirs.state}/orchard";
      defaultText = lib.literalExpression ''"''${XDG_STATE_HOME}/orchard"'';
      description = "Where the generated files and palette.json live.";
    };

    target = lib.mkOption {
      type = lib.types.str;
      default = "graphical-session.target";
      example = "sway-session.target";
      description = "The systemd user target that starts the service.";
    };

    targets = lib.mkOption {
      type = lib.types.attrsOf targetType;
      default = { };
      description = "Files to keep filled from the wallpaper's palette.";
    };

    sway = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          Keep sway's window and bar colours in `targets."sway.conf"`. Add
          its `fallback` and an `include` of its `path` to the sway config,
          after the bar blocks.
        '';
      };

      bars = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ "bar-0" ];
        description = "Bar ids to colour; sway names unnamed bars bar-0, bar-1, …";
      };
    };

    fuzzel = {
      enable = lib.mkEnableOption ''
        fuzzel colours in `targets."fuzzel.ini"`. End fuzzel.ini with a
        `[main]` section that has `include=` its `path`
      '';

      colours = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = { };
        example = {
          background = "{{surface.background|bare}}ff";
        };
        description = "Overrides for the [colors] that orchard's fuzzel port would write.";
      };
    };

    swaynag.enable = lib.mkEnableOption ''
      swaynag colours, written to swaynag's own config file, where swaynag
      finds them with no flag
    '';

    configFile = lib.mkOption {
      type = lib.types.path;
      readOnly = true;
      default = configFile;
      defaultText = lib.literalExpression "the generated settings and targets";
      description = "What the service is started with: `orchard-wallpaper watch --config` this.";
    };

    palette = lib.mkOption {
      type = lib.types.str;
      readOnly = true;
      default = "${cfg.stateDirectory}/palette.json";
      description = "The current palette as JSON, in the shape of `config.orchard.palette`.";
    };
  };

  config = lib.mkIf (config.orchard.enable && cfg.enable) (
    lib.mkMerge [
      {
        orchard.wallpaper.targets = lib.mkMerge [
          (lib.mkIf cfg.sway.enable {
            "sway.conf" = {
              template = swayTemplate;
              sway = true;
            };
          })
          (lib.mkIf cfg.fuzzel.enable { "fuzzel.ini".template = fuzzelTemplate; })
          (lib.mkIf cfg.swaynag.enable {
            swaynag = {
              template = swaynagTemplate;
              path = "${dirs.config}/swaynag/config";
            };
          })
        ];
      }

      (lib.optionalAttrs (class == "hjem" && options ? systemd) {
        packages = [ cfg.package ];
        systemd.services.orchard-wallpaper = {
          description = "Colours from the wallpaper sway shows";
          wantedBy = [ cfg.target ];
          partOf = [ cfg.target ];
          after = [ cfg.target ];
          serviceConfig = {
            ExecStart = command;
            Restart = "on-failure";
            RestartSec = 2;
          };
        };
      })

      (lib.optionalAttrs (class == "home" && options ? systemd) {
        home.packages = [ cfg.package ];
        systemd.user.services.orchard-wallpaper = {
          Unit = {
            Description = "Colours from the wallpaper sway shows";
            PartOf = [ cfg.target ];
            After = [ cfg.target ];
          };
          Service = {
            ExecStart = command;
            Restart = "on-failure";
            RestartSec = 2;
          };
          Install.WantedBy = [ cfg.target ];
        };
      })
    ]
  );
}
