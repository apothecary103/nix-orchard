{
  lib,
  pkgs,
  engine,
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

  failures = lib.concatLists (
    lib.mapAttrsToList (
      themeName: theme:
      lib.concatMap (
        flavor: lib.concatMap (accent: checkPalette themeName theme flavor accent) (palette.accentsOf theme)
      ) (palette.flavorsOf theme)
    ) themes
  );

  # A port that names something outside the vocabulary breaks every theme at
  # once, so every class binding is rendered against a palette of sentinel
  # values. `cfg` carries the union of the ports' extra options, since a probe
  # has no option tree to read defaults out of.
  probe = lib.genAttrs required (_: "#abcdef") // {
    isLight = false;
    raw = { };
    rainbow = lib.genList (_: "#abcdef") 6;
    ansi = lib.genList (_: "#abcdef") 16;
  };

  render =
    class: transparent: upstream: name: port:
    let
      given = port.${class};
      body = if lib.isFunction given then given else given.config;

      args = {
        inherit lib pkgs;
        config = { };
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
        upstream = if upstream then "probe-upstream" else null;
        port = name;
      };
    in
    body (args // lib.optionalAttrs (port ? theme) { data = port.theme args; });

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
                lib.mapAttrsToList (render class transparent upstream) (
                  lib.filterAttrs (_: port: port ? ${class}) ports
                )
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
in
{
  modules = pkgs.runCommandLocal "themes-modules" {
    covered = toString (lib.unique resolved);
  } "touch $out";

  palettes = pkgs.runCommandLocal "themes-palettes" { } (
    if failures == [ ] then
      "touch $out"
    else
      "echo ${lib.escapeShellArg (lib.concatStringsSep "\n" failures)} >&2; exit 1"
  );

  ports = pkgs.runCommandLocal "themes-ports" {
    covered = builtins.seq (force rendered) (toString (lib.attrNames ports));
  } "touch $out";
}
