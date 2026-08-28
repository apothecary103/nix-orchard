{
  lib,
  pkgs,
  engine,
  homeManager,
}:

let
  inherit (engine) palette themes ports;

  # Every name a port is allowed to reach for. A theme that misses one of these
  # would only fail once some unrelated program was enabled, so it is checked
  # here instead.
  required =
    palette.surfaces
    ++ palette.hues
    ++ lib.attrNames (palette.compat (lib.genAttrs palette.hues (_: "#000000")))
    ++ lib.attrNames (palette.roles (lib.genAttrs (palette.surfaces ++ palette.hues) (_: "#000000")))
    ++ [ "accent" ];

  hex = lib.match "#[0-9a-fA-F]{6}";

  checkPalette =
    themeName: theme: flavor: accent:
    let
      p = palette.mkPalette theme { inherit flavor accent; };

      missing = lib.filter (name: !(p ? ${name})) required;

      malformed = lib.filter (name: lib.isString p.${name} && hex p.${name} == null) (
        lib.filter (name: p ? ${name}) required
      );
    in
    lib.optional (missing != [ ]) "${themeName}/${flavor}/${accent}: missing ${toString missing}"
    ++ lib.optional (
      malformed != [ ]
    ) "${themeName}/${flavor}/${accent}: not #rrggbb: ${toString malformed}";

  paletteFailures = lib.concatLists (
    lib.mapAttrsToList (
      themeName: theme:
      lib.concatMap (
        flavor: lib.concatMap (accent: checkPalette themeName theme flavor accent) (palette.accentsOf theme)
      ) (palette.flavorsOf theme)
    ) themes
  );

  themeFailures = lib.concatLists (
    lib.mapAttrsToList (
      themeName: theme:
      let
        flavors = palette.flavorsOf theme;
        accents = palette.accentsOf theme;
        integrations = theme.integrations or { };
        unknownIntegrations = lib.filter (name: !(ports ? ${name}) || !(ports.${name} ? integration)) (
          lib.attrNames integrations
        );
        invalidKinds = lib.filter (
          name:
          !(lib.elem integrations.${name}.kind [
            "builtin"
            "official"
          ])
        ) (lib.attrNames integrations);
      in
      lib.optional (!(lib.isString theme.source)) "${themeName}: source must be a string"
      ++ lib.optional (
        !(lib.elem theme.defaultFlavor flavors)
      ) "${themeName}: default flavor ${theme.defaultFlavor} is not declared"
      ++ lib.optional (
        !(lib.elem theme.defaultAccent accents)
      ) "${themeName}: default accent ${theme.defaultAccent} is not declared"
      ++ lib.optional (
        !(lib.all (flavor: lib.elem flavor flavors) (theme.lightFlavors or [ ]))
      ) "${themeName}: lightFlavors contains an unknown flavor"
      ++ lib.optional (
        unknownIntegrations != [ ]
      ) "${themeName}: integrations without capable ports: ${toString unknownIntegrations}"
      ++ lib.optional (
        invalidKinds != [ ]
      ) "${themeName}: integrations with invalid kinds: ${toString invalidKinds}"
    ) themes
  );

  failures = paletteFailures ++ themeFailures;

  # A port that names something outside the vocabulary breaks every theme at
  # once, so every class binding is rendered against a palette of sentinel
  # values. `cfg` carries the union of the ports' extra options, since a probe
  # has no option tree to read defaults out of.
  probeValue = "#abcdef";

  probe = lib.genAttrs required (_: probeValue) // {
    isLight = false;
    raw = { };
    native = { };
    rainbow = lib.genList (_: probeValue) 6;
    ansi = lib.genList (_: probeValue) 16;

    surface = lib.genAttrs [
      "shadow"
      "panel"
      "background"
      "neutral0"
      "neutral1"
      "neutral2"
      "neutral3"
      "neutral4"
      "neutral5"
      "textDim"
      "textMuted"
      "text"
    ] (_: probeValue);
    hue = lib.genAttrs palette.hues (_: probeValue);
    syntax = lib.genAttrs (palette.syntaxRoles ++ [ "function" ]) (_: probeValue);
    ui = lib.genAttrs (palette.uiRoles ++ [ "cursorLine" ]) (_: probeValue);
    status = lib.genAttrs (
      palette.statusRoles
      ++ [
        "success"
        "diffAdded"
        "diffDeleted"
        "diffChanged"
      ]
    ) (_: probeValue);
    statusBar = lib.genAttrs [
      "background"
      "foreground"
      "dim"
    ] (_: probeValue);
    decorative.rainbow = lib.genList (_: probeValue) 6;
    terminal.ansi = lib.genList (_: probeValue) 16;
    named = lib.genAttrs required (_: probeValue);
  };

  programNames = lib.unique (
    lib.attrNames ports
    ++ [
      "git"
      "zsh"
    ]
  );

  fakeConfig = {
    packages = [ ];
    home.packages = [ ];
    rum.programs = lib.genAttrs programNames (_: {
      enable = true;
    });
    programs =
      lib.genAttrs programNames (_: {
        enable = true;
      })
      // {
        zsh = {
          enable = true;
          syntaxHighlighting.enable = true;
        };
      };
    services = lib.genAttrs programNames (_: {
      enable = true;
    });
  };

  render =
    class: transparent: upstream: name: port: supplied:
    let
      given = port.${class};
      body = if lib.isFunction given then given else given.config;
      when = if lib.isFunction given then (_: true) else given.when or (_: true);

      args = {
        p = probe;
        cfg = {
          inherit transparent;
          configFile = "tmux/probe.conf";
        };
        name = "probe";
        theme = "probe";
        flavor = "probe";
        accent = "probe";
        spec = { };
        inherit upstream;
      }
      // supplied
      // {
        inherit lib pkgs;
        config = fakeConfig;
        port = name;
      };

      tune = (args.spec.ports or { }).${name} or (_: data: data);
      themed = lib.optionalAttrs (port ? theme) {
        data = tune args (port.theme args);
      };
    in
    builtins.seq (when args) (body (args // themed));

  # `builtins.deepSeq` would descend into a derivation's self-referential
  # attributes and never come back, so derivations are forced to their drvPath
  # and left alone.
  force =
    v:
    if lib.isDerivation v then
      builtins.seq v.drvPath null
    else if lib.isAttrs v then
      lib.foldl' (_: x: builtins.seq (force x) null) null (lib.attrValues v)
    else if lib.isList v then
      lib.foldl' (_: x: builtins.seq (force x) null) null v
    else if lib.isFunction v then
      null
    else
      builtins.seq v null;

  rendered =
    lib.concatMap
      (
        class:
        lib.concatMap
          (
            transparent:
            lib.concatMap
              (
                upstream:
                lib.mapAttrsToList (
                  name: port:
                  render class transparent (if upstream then "probe-upstream" else null) name port {
                    accent = "probe";
                    flavor = "probe";
                    name = "probe";
                    p = probe;
                    spec = { };
                    theme = "probe";
                  }
                ) (lib.filterAttrs (_: port: port ? ${class}) ports)
              )
              [
                false
                true
              ]
          )
          [
            false
            true
          ]
      )
      [
        "hjem"
        "home"
        "nixos"
      ];

  # Every real theme hook is rendered for every flavor and class. This catches
  # raw/native palette assumptions and theme-specific port overrides which the
  # sentinel probe deliberately cannot model.
  themedRendered = lib.concatLists (
    lib.mapAttrsToList (
      themeName: spec:
      lib.concatMap (
        flavor:
        let
          accent = spec.defaultAccent;
          p = palette.mkPalette spec { inherit flavor accent; };
        in
        lib.concatMap
          (
            class:
            lib.concatMap
              (
                transparent:
                lib.mapAttrsToList (
                  name: port:
                  let
                    declared = (spec.integrations or { }).${name} or null;
                    upstream = if declared == null then null else declared.name flavor;
                    baseName = if upstream == null then palette.nameOf spec flavor else upstream;
                    cfg = {
                      inherit transparent;
                      configFile = "tmux/probe.conf";
                    };
                    resolvedName = (port.resolveName or ({ name, ... }: name)) {
                      name = baseName;
                      inherit upstream cfg;
                    };
                  in
                  render class transparent upstream name port {
                    inherit
                      accent
                      cfg
                      flavor
                      p
                      spec
                      ;
                    name = resolvedName;
                    theme = themeName;
                  }
                ) (lib.filterAttrs (_: port: port ? ${class}) ports)
              )
              [
                false
                true
              ]
          )
          [
            "hjem"
            "home"
            "nixos"
          ]
      ) (palette.flavorsOf spec)
    ) themes
  );
  # The option trees, evaluated without hjem or home-manager underneath them.
  # Every port is left disabled, so the sinks below only have to exist — this
  # catches a clash between two ports' options, not a wrong option path.
  sink = lib.mkOption {
    type = lib.types.attrs;
    default = { };
  };

  stub.options = lib.genAttrs [
    "console"
    "environment"
    "home"
    "programs"
    "rum"
    "services"
    "xdg"
  ] (_: sink);

  evalSelector =
    orchard:
    (lib.evalModules {
      class = "homeManager";
      specialArgs = { inherit pkgs; };
      modules = [
        (engine.mkModule "home")
        stub
        { inherit orchard; }
      ];
    }).config.orchard;

  defaultSelection = evalSelector {
    enable = false;
    theme = "catppuccin";
  };

  customSelection = evalSelector {
    enable = false;
    theme = "catppuccin";
    accent = "blue";
    btop.theme = "gruvbox";
    helix = {
      theme = "gruvbox";
      transparent = true;
    };
    micro = {
      theme = "gruvbox";
      transparent = true;
    };
  };

  unavailableUpstream = builtins.tryEval (
    (evalSelector {
      enable = false;
      theme = "evergarden";
      helix.source = "upstream";
    }).helix.themeName
  );

  selectorFailures =
    lib.optional (
      defaultSelection.helix.resolvedSource != "builtin"
    ) "default Catppuccin Helix should use its builtin"
    ++ lib.optional (
      customSelection.btop.themeName != "gruvbox_dark_v2"
    ) "per-port theme selection did not resolve Gruvbox for btop"
    ++ lib.optional (
      customSelection.btop.resolvedSource != "builtin"
    ) "per-port Gruvbox btop should use its builtin"
    ++ lib.optional (
      customSelection.helix.themeName != "gruvbox-transparent"
    ) "transparent Helix builtin did not resolve its wrapper name"
    ++ lib.optional (
      customSelection.helix.resolvedSource != "builtin"
    ) "transparent Helix should retain its capable builtin"
    ++ lib.optional (
      customSelection.micro.resolvedSource != "generated"
    ) "transparent Micro should fall back to a generated theme"
    ++ lib.optional unavailableUpstream.success "forcing a missing upstream integration should fail";

  # Every theme is worn in turn, with the ports left disabled so the stubs above
  # only have to exist. This proves the selector resolves each theme's default
  # flavor and accent, and that the option tree merges.
  optionTree =
    class: moduleClass: theme:
    (lib.evalModules {
      class = moduleClass;
      specialArgs = { inherit pkgs; };
      modules = [
        (engine.mkModule class)
        stub
        {
          orchard = {
            enable = false;
            inherit theme;
          };
        }
      ];
    }).options;

  # Forcing the tree wholesale would walk into `_module` and never come back, so
  # only the leaves worth proving are read: every port's resolved theme name.
  names =
    class: moduleClass:
    lib.concatMap (
      theme:
      let
        tree = (optionTree class moduleClass theme).orchard;
      in
      map (key: tree.${key}.themeName.default) (
        lib.filter (key: lib.isAttrs tree.${key} && tree.${key} ? themeName) (lib.attrNames tree)
      )
    ) (lib.attrNames themes);

  resolved = lib.concatLists (
    lib.mapAttrsToList names {
      hjem = "hjem";
      home = "homeManager";
      nixos = "nixos";
    }
  );

  homePorts = lib.filterAttrs (_: port: port ? home) ports;

  homeSmoke = homeManager.lib.homeManagerConfiguration {
    inherit pkgs;
    modules = [
      (engine.mkModule "home")
      {
        home = {
          username = "orchard";
          homeDirectory = if pkgs.stdenv.hostPlatform.isDarwin then "/Users/orchard" else "/home/orchard";
          stateVersion = "26.05";
        };

        programs = {
          bat.enable = true;
          btop.enable = true;
          eza.enable = true;
          fish.enable = true;
          fzf.enable = true;
          git.enable = true;
          helix.enable = true;
          lazygit.enable = true;
          micro.enable = true;
          starship.enable = true;
          tmux.enable = true;
          wezterm.enable = true;
          yazi.enable = true;
          zellij.enable = true;
          zsh = {
            enable = true;
            syntaxHighlighting.enable = true;
          };
        };

        orchard = {
          enable = true;
          autoEnable = false;
          theme = "catppuccin";
          accent = "blue";
        }
        // lib.mapAttrs (_: _: { enable = true; }) homePorts;
      }
    ];
  };
in
{
  modules =
    pkgs.runCommandLocal "themes-modules"
      {
        covered = toString (lib.unique resolved);
      }
      (
        if selectorFailures == [ ] then
          "touch $out"
        else
          "echo ${lib.escapeShellArg (lib.concatStringsSep "\n" selectorFailures)} >&2; exit 1"
      );

  home-manager = pkgs.runCommandLocal "themes-home-manager" {
    covered = builtins.unsafeDiscardStringContext homeSmoke.activationPackage.drvPath;
  } "touch $out";

  palettes = pkgs.runCommandLocal "themes-palettes" { } (
    if failures == [ ] then
      "touch $out"
    else
      "echo ${lib.escapeShellArg (lib.concatStringsSep "\n" failures)} >&2; exit 1"
  );

  ports = pkgs.runCommandLocal "themes-ports" {
    covered = builtins.seq (force rendered) (
      builtins.seq (force themedRendered) (toString (lib.attrNames ports))
    );
  } "touch $out";
}
