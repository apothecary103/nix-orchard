{
  lib,
  pkgs,
  engine,
  homeManager,
  hjem,
  hjemRum,
}:

let
  inherit (engine) palette themes ports;

  # A theme missing one of these would only fail once some program was enabled.
  required =
    palette.surfaces
    ++ palette.hues
    ++ palette.syntaxRoles
    ++ palette.uiRoles
    ++ palette.statusRoles
    ++ palette.statusBarRoles;

  hex = lib.match "#[0-9a-fA-F]{6}";

  checkPalette =
    themeName: theme: flavor: accent:
    let
      p = palette.mkPalette theme { inherit flavor accent; };

      missing = lib.filter (name: !(p.named ? ${name})) required;

      # The colours `named` cannot carry: positions rather than names.
      loose = [ p.ui.accent ] ++ p.decorative.rainbow ++ p.terminal.ansi;

      malformed =
        lib.filter (name: hex p.named.${name} == null) (lib.filter (name: p.named ? ${name}) required)
        ++ lib.filter (colour: hex colour == null) loose;

      publicGroups = {
        syntax = palette.publicSyntaxRoles;
        ui = palette.publicUiRoles;
        status = palette.publicStatusRoles;
      };

      wrongPublicGroups = lib.filter (
        group: lib.attrNames p.${group} != lib.sort lib.lessThan publicGroups.${group}
      ) (lib.attrNames publicGroups);
    in
    lib.optional (missing != [ ]) "${themeName}/${flavor}/${accent}: missing ${toString missing}"
    ++ lib.optional (
      malformed != [ ]
    ) "${themeName}/${flavor}/${accent}: not #rrggbb: ${toString malformed}"
    ++ lib.optional (
      lib.length p.decorative.rainbow != 6
    ) "${themeName}/${flavor}/${accent}: rainbow is not 6 colours"
    ++ lib.optional (
      lib.length p.terminal.ansi != 16
    ) "${themeName}/${flavor}/${accent}: ansi is not 16 colours"
    ++ lib.optional (
      wrongPublicGroups != [ ]
    ) "${themeName}/${flavor}/${accent}: non-canonical public groups ${toString wrongPublicGroups}";

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

  evergardenSpec = themes.evergarden;
  evergardenPalette = palette.mkPalette evergardenSpec {
    flavor = "fall";
    accent = evergardenSpec.defaultAccent;
  };
  evergardenArgs = {
    inherit lib pkgs;
    p = evergardenPalette;
    cfg.transparent = false;
    name = "evergarden-fall";
    theme = "evergarden";
    flavor = "fall";
    accent = evergardenSpec.defaultAccent;
    spec = evergardenSpec;
    upstream = null;
  };
  evergardenHelix = evergardenSpec.ports.helix evergardenArgs (ports.helix.theme evergardenArgs);
  evergardenYazi = ports.yazi.theme evergardenArgs;
  evergardenBat = evergardenSpec.ports.bat evergardenArgs (ports.bat.theme evergardenArgs);
  evergardenBatFile = pkgs.writeText "evergarden-fall.tmTheme" evergardenBat;
  evergardenModePairs = lib.concatMap (
    flavor:
    lib.concatMap (
      accent:
      let
        p = palette.mkPalette evergardenSpec { inherit flavor accent; };
      in
      map
        (state: {
          label = "${flavor}/${accent}/${state}";
          foreground = p.statusBar.mode.foreground;
          background = p.statusBar.mode.${state};
        })
        [
          "normal"
          "insert"
          "select"
        ]
    ) (palette.accentsOf evergardenSpec)
  ) (palette.flavorsOf evergardenSpec);
  evergardenModePairsFile = pkgs.writeText "evergarden-mode-pairs.json" (
    builtins.toJSON evergardenModePairs
  );

  evergardenFailures =
    lib.optional (
      evergardenHelix.type != {
        fg = "type";
        modifiers = [ "italic" ];
      }
    ) "evergarden: Helix types must retain upstream's italic yellow style"
    ++ lib.optional (
      evergardenHelix."function.macro" != "aqua"
    ) "evergarden: Helix macros must retain upstream's aqua Tree-sitter capture"
    ++ lib.optional (
      evergardenHelix."markup.link.url" != "blue"
    ) "evergarden: Helix URLs must retain upstream's blue capture"
    ++ lib.optional (
      evergardenHelix."ui.cursorline.primary" != { bg = "surface0"; }
    ) "evergarden: Helix cursorline must use upstream's surface0"
    ++ lib.optional (
      evergardenPalette.statusBar.foreground != evergardenPalette.surface.text
      || evergardenPalette.statusBar.inactive != evergardenPalette.surface.textDim
      || evergardenPalette.statusBar.dim != evergardenPalette.surface.neutral4
    ) "evergarden: statusline emphasis tiers are no longer distinct"
    ++ lib.optional (
      evergardenPalette.statusBar.mode.foreground != evergardenPalette.surface.text
      || evergardenHelix."ui.statusline.normal".fg != "statusModeFg"
      || evergardenYazi.mode.normal_main.fg != evergardenPalette.statusBar.mode.foreground
    ) "evergarden: applications bypassed the shared high-contrast mode-line role"
    ++ lib.optional (
      !(lib.hasInfix "Evergarden documentation strings" evergardenBat)
      || !(lib.hasInfix "Evergarden raw markup" evergardenBat)
      || !(lib.hasInfix "Evergarden function macros" evergardenBat)
    ) "evergarden: Bat lost its semantic TextMate overrides";

  failures = paletteFailures ++ themeFailures ++ evergardenFailures;

  # A port naming something outside the vocabulary breaks every theme at once.
  probeValue = "#abcdef";

  probe = {
    isLight = false;
    native = { };

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
    syntax = lib.genAttrs palette.publicSyntaxRoles (_: probeValue);
    ui = lib.genAttrs palette.publicUiRoles (_: probeValue);
    status = lib.genAttrs palette.publicStatusRoles (_: probeValue);
    statusBar =
      lib.genAttrs [
        "background"
        "foreground"
        "inactive"
        "dim"
      ] (_: probeValue)
      // {
        mode = lib.genAttrs [
          "foreground"
          "normal"
          "insert"
          "select"
        ] (_: probeValue);
      };
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

  # `deepSeq` never returns from a derivation's self-referential attributes.
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

  # Catches `native` assumptions and theme hooks, which the probe cannot model.
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
  # Catches a clash between two ports' options, not a wrong option path.
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
    # Global accents guide generated ports without replacing a hand-tuned
    # upstream theme that uses the theme's own fixed accent choices.
    accent = "blue";
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

  # Proves every theme's default flavor and accent resolve and the tree merges.
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

  # Forcing the whole tree would walk into `_module` and never come back.
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

  hjemPorts = lib.filterAttrs (_: port: port ? hjem) ports;

  # Pinned to Linux, not the host: gating on `isLinux` would no-op on darwin.
  hjemSmoke = lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      hjem.nixosModules.default
      {
        system.stateVersion = "26.05";

        # The least NixOS' own assertions accept, so the list below stays ours.
        boot.loader.grub.enable = false;
        fileSystems."/" = {
          device = "/dev/null";
          fsType = "ext4";
        };

        users = {
          groups.orchard = { };
          users.orchard = {
            isNormalUser = true;
            group = "orchard";
          };
        };

        hjem = {
          extraModules = [
            hjemRum.hjemModules.default
            (engine.mkModule "hjem")
          ];

          users.orchard = {
            enable = true;
            directory = "/home/orchard";
            user = "orchard";

            # tofi is missing on purpose: hjem-rum's module misuses toKeyValue.
            rum.programs = {
              alacritty.enable = true;
              fish.enable = true;
              foot.enable = true;
              fuzzel.enable = true;
              fzf.enable = true;
              ghostty.enable = true;
              helix.enable = true;
              imv.enable = true;
              kitty.enable = true;
              starship.enable = true;
              yazi.enable = true;
              zsh.enable = true;
            };

            orchard = {
              enable = true;
              autoEnable = false;
              theme = "catppuccin";
              accent = "blue";
            }
            // lib.mapAttrs (_: _: { enable = true; }) hjemPorts;
          };
        };
      }
    ];
  };

  # The hjem equivalent of an activation package, without the system closure.
  hjemUser = hjemSmoke.config.hjem.users.orchard;

  hjemFiles = lib.concatMap lib.attrValues [
    hjemUser.files
    hjemUser.xdg.cache.files
    hjemUser.xdg.config.files
    hjemUser.xdg.data.files
    hjemUser.xdg.state.files
  ];

  hjemFailures = map (entry: entry.message) (
    lib.filter (entry: !entry.assertion) hjemSmoke.config.assertions
  );
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

  hjem =
    pkgs.runCommandLocal "themes-hjem"
      {
        covered = builtins.seq (force hjemFiles) (toString (map (file: file.target) hjemFiles));
      }
      (
        if hjemFailures == [ ] then
          "touch $out"
        else
          "echo ${lib.escapeShellArg (lib.concatStringsSep "\n" hjemFailures)} >&2; exit 1"
      );

  palettes = pkgs.runCommandLocal "themes-palettes" { nativeBuildInputs = [ pkgs.python3 ]; } (
    if failures == [ ] then
      ''
        python - ${evergardenModePairsFile} <<'PY'
        import json
        import sys

        def luminance(colour):
            channels = [int(colour[i:i + 2], 16) / 255 for i in (1, 3, 5)]
            linear = [c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4 for c in channels]
            return 0.2126 * linear[0] + 0.7152 * linear[1] + 0.0722 * linear[2]

        failures = []
        with open(sys.argv[1]) as source:
            for pair in json.load(source):
                foreground = luminance(pair["foreground"])
                background = luminance(pair["background"])
                ratio = (max(foreground, background) + 0.05) / (min(foreground, background) + 0.05)
                if ratio < 4.5:
                    failures.append(f'{pair["label"]}: {ratio:.2f}:1')

        if failures:
            raise SystemExit("evergarden mode-line contrast below 4.5:1:\n" + "\n".join(failures))
        PY
        touch $out
      ''
    else
      "echo ${lib.escapeShellArg (lib.concatStringsSep "\n" failures)} >&2; exit 1"
  );

  ports =
    pkgs.runCommandLocal "themes-ports"
      {
        covered = builtins.seq (force rendered) (
          builtins.seq (force themedRendered) (toString (lib.attrNames ports))
        );
        nativeBuildInputs = [ pkgs.bat ];
      }
      ''
        mkdir -p theme-source/themes bat-cache
        cp ${evergardenBatFile} theme-source/themes/evergarden-fall.tmTheme
        BAT_CONFIG_PATH=/dev/null bat cache --build \
          --source=theme-source --target=bat-cache
        touch $out
      '';
}
