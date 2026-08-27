{ lib, ... }:

{
  name = "onedark";
  description = "Atom's One, dark and light";

  palettes = import ./palettes.nix;

  defaultFlavor = "dark";
  lightFlavors = [ "light" ];

  accents = lib.genAttrs [
    "red"
    "orange"
    "yellow"
    "green"
    "aqua"
    "blue"
    "purple"
  ] lib.id;

  defaultAccent = "blue";

  # Atom's own names, which every program spells slightly differently.
  integrations = {
    helix = {
      kind = "builtin";
      name = flavor: if flavor == "light" then "onelight" else "onedark";
    };
    btop = {
      kind = "builtin";
      name = flavor: if flavor == "light" then null else "onedark";
    };
    micro = {
      kind = "builtin";
      name = flavor: if flavor == "light" then null else "one-dark";
    };
    vivid = {
      kind = "builtin";
      name = flavor: if flavor == "light" then "one-light" else "one-dark";
    };
    zellij = {
      kind = "builtin";
      name = flavor: if flavor == "light" then null else "onedark";
    };
  };

  colours = { raw, ... }: raw;

  # One's grammar, which is the reason it reads so cleanly: purple keywords,
  # blue functions, green strings, yellow types, orange numbers and constants,
  # and cyan for anything built in.
  roles = p: {
    comment = p.overlay1;

    keyword = p.purple;
    func = p.blue;
    macro = p.aqua;
    type = p.yellow;
    constant = p.orange;
    number = p.orange;
    string = p.green;
    escape = p.aqua;
    special = p.aqua;
    variable = p.red;
    property = p.red;
    module = p.yellow;
    annotation = p.orange;
    operator = p.aqua;
    punctuation = p.subtext0;

    error = p.red;
    warning = p.yellow;
    info = p.blue;
    hint = p.aqua;
    ok = p.green;

    add = p.green;
    delete = p.red;
    change = p.yellow;

    search = p.yellow;
    match = p.orange;
    title = p.blue;

    rainbow = [
      p.red
      p.orange
      p.yellow
      p.green
      p.aqua
      p.blue
    ];

    ansi = [
      (if p.isLight then p.mantle else p.crust)
      p.red
      p.green
      p.yellow
      p.blue
      p.purple
      p.aqua
      p.subtext0
      p.overlay1
      p.red
      p.green
      p.yellow
      p.blue
      p.purple
      p.aqua
      p.text
    ];
  };
}
