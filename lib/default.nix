{ lib }:

let
  render = import ./render.nix { inherit lib; };
  palette = import ./palette.nix { inherit lib; };

  loadDir =
    dir:
    lib.mapAttrs' (file: _: {
      name = lib.removeSuffix ".nix" file;
      value = import (dir + "/${file}") { inherit lib render; };
    }) (lib.filterAttrs (file: kind: kind == "regular" || kind == "directory") (builtins.readDir dir));
in
rec {
  inherit render palette;

  inherit (render) noHash;

  # program -> { description, options?, theme?, hjem?, home?, nixos? }. A port
  # names the palette's roles and nothing else, so one definition serves every
  # theme.
  ports = loadDir ../ports;

  # name -> theme spec, as consumed by palette.mkPalette.
  themes = loadDir ../themes;

  mkPalette = theme: palette.mkPalette themes.${theme};

  # One module per class, carrying every theme. Which one is worn is an option
  # rather than a choice of import, so nothing downstream has to name a theme.
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
