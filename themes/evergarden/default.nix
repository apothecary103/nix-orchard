{ lib, ... }:

{
  description = "Comfy & fancy, warm and green";
  source = "https://codeberg.org/evergarden/nvim";

  palettes = import ./palettes.nix;

  defaultFlavor = "fall";

  # Summer is the only variant whose ramp runs the other way: its `text` is dark
  # and its `surface*` are light.
  lightFlavors = [ "summer" ];

  # Evergarden is drawn in the engine's own vocabulary, so every hue doubles as
  # an accent and nothing has to be renamed.
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

  # helix has never heard of evergarden, so rather than settle for the engine's
  # generated theme it gets one written by hand against helix's scope list. The
  # port's palette table and its transparency handling are kept.
  ports.helix =
    { p, lib, ... }:
    data: data // import ./helix.nix { inherit p lib; };

  colours = { raw, ... }: raw;

  # evergarden.nvim's own choices where they differ from the engine defaults: a
  # dimmer statusline than the ramp suggests, and cherry for attributes. Its
  # `@operator` is subtext0 — only `@keyword.operator` is orange, which the
  # helix theme spells out on its own.
  roles = p: {
    annotation = p.cherry;
    module = p.snow;

    # `text`, not the `subtext0` vim's bare StatusLine falls back to: every
    # statusline anyone actually runs — mini.statusline's Filename section,
    # lualine's — puts the bright foreground on the mantle, and a helix or yazi
    # modeline is that kind of bar, not vim's undecorated one.
    statusBg = p.mantle;
    statusFg = p.text;
    statusDim = p.subtext0;
  };
}
