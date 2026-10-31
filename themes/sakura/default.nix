{ lib, ... }:

{
  description = "Soft greys and a calm pink, tuned by hand";
  source = "https://github.com/apothecary103/nix-orchard";

  palettes = import ./palettes.nix;

  defaultFlavor = "night";
  lightFlavors = [ "day" ];

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

  defaultAccent = "pink";

  colours = { raw, ... }: raw;

  roles = p: {
    keyword = p.pink;
    func = p.blue;
    macro = p.purple;
    type = p.yellow;
    constant = p.orange;
    number = p.orange;
    string = p.green;
    special = p.aqua;
    property = p.skye;
    module = p.purple;
    annotation = p.purple;

    title = p.pink;
    match = p.pink;
    secondaryAccent = p.purple;
  };
}
