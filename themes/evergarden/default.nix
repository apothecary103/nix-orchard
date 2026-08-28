{ lib, ... }:

{
  description = "Comfy & fancy, warm and green";
  source = "https://codeberg.org/evergarden/nvim";

  palettes = import ./palettes.nix;

  defaultFlavor = "fall";

  # Summer is the only variant whose ramp runs the other way.
  lightFlavors = [ "summer" ];

  # Drawn in the engine's own vocabulary, so every hue doubles as an accent.
  accents = lib.genAttrs [
    "red"
    "orange"
    "yellow"
    "lime"
    "green"
    "aqua"
    "skye"
    "snow"
    "blue"
    "purple"
    "pink"
    "cherry"
  ] lib.id;

  defaultAccent = "green";

  # helix has never heard of evergarden, so its theme is written by hand.
  ports.helix =
    { p, lib, ... }:
    data: data // import ./helix.nix { inherit p lib; };

  colours = { raw, ... }: raw;

  # evergarden.nvim's choices where they differ from the engine defaults.
  roles = p: {
    annotation = p.cherry;
    module = p.snow;

    # `text`, not the `subtext0` vim's undecorated StatusLine falls back to.
    statusBg = p.mantle;
    statusFg = p.text;
    statusDim = p.subtext0;
  };
}
