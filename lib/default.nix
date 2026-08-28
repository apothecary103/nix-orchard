{ lib }:

let
  render = import ./render.nix { inherit lib; };
  palette = import ./palette.nix { inherit lib; };

  loadDir =
    dir:
    lib.mapAttrs'
      (file: _: {
        name = lib.removeSuffix ".nix" file;
        value = import (dir + "/${file}") { inherit lib render; };
      })
      (
        lib.filterAttrs (
          file: kind:
          (kind == "regular" && lib.hasSuffix ".nix" file)
          || (kind == "directory" && builtins.pathExists (dir + "/${file}/default.nix"))
        ) (builtins.readDir dir)
      );
in
rec {
  inherit render palette;

  inherit (render) noHash;

  # A port names palette roles and nothing else, so one definition fits every theme.
  ports = loadDir ../ports;

  themes = lib.mapAttrs (name: theme: theme // { inherit name; }) (loadDir ../themes);

  mkPalette = theme: palette.mkPalette themes.${theme};

  # One module per class carrying every theme, so the choice stays an option.
  mkModule =
    class:
    import ../modules/select.nix {
      inherit
        lib
        class
        themes
        ports
        palette
        ;
    };
}
