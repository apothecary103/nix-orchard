# Orchard

A shared theme system for Nix. Pick a theme once and every program you already use gets themed to match.

```nix
{
  inputs.orchard.url = "github:apothecary103/nix-orchard";

  # NixOS
  imports = [ inputs.orchard.nixosModules.default ];

  # hjem
  imports = [ inputs.orchard.hjemModules.default ];

  # home-manager
  imports = [ inputs.orchard.homeModules.default ];
}
```

```nix
{
  orchard = {
    enable = true;
    theme = "catppuccin";
    flavour = "macchiato"; # `flavor` works too; null takes the theme's default
    accent = "blue";       # likewise

    transparent = true;       # where a program can be told to skip its background
    ghostty.enable = false;   # opt out of one port
    btop.theme = "gruvbox";   # or theme one program differently
    yazi.transparent = false; # or keep one opaque
  };
}
```

Pick a flavour or accent the theme does not have and you get told so, with the list of the ones it does:

```
orchard: macchiato is not a flavor of gruvbox. Choose one of dark, dark-hard,
dark-soft, light, light-hard, light-soft
```

## Which programs get themed

By default Orchard themes the programs you have already enabled, plus the ones
that only need a file dropped somewhere if they are in your packages. That is
`autoEnable`. Turn it off and nothing is themed until you ask:

```nix
orchard.autoEnable = false;
orchard.helix.enable = true;
```

Either way, `orchard.<port>.enable` decides a single program.

These are the programs Orchard knows:

`alacritty` `bat` `btop` `console` `delta` `eza` `fish` `foot` `fuzzel` `fzf`
`ghostty` `glamour` `helix` `imv` `kitty` `lazygit` `mako` `micro` `rmpc`
`starship` `tmux` `tofi` `vivid` `wezterm` `yazi` `zathura` `zellij`
`zsh-syntax-highlighting`

Most work under hjem and home-manager. `lazygit`, `mako` and `zathura` are
home-manager only, and the Linux virtual `console` is NixOS only.

`helix`, `yazi`, `fzf` and `micro` can skip their background, and follow
`orchard.transparent` unless you set their own.

## Using the palette elsewhere

For anything Orchard does not cover, such as a bar or a compositor, take the
colours yourself from `config.orchard.palette` or the `orchardPalette` module
argument:

```nix
{ orchardPalette, ... }:
{
  programs.niri.settings.layout.focus-ring.active.color = orchardPalette.ui.accent;
}
```

Every theme resolves to the same names:

| group | names |
| --- | --- |
| `surface` | `shadow` `panel` `background` `neutral0…5` `textDim` `textMuted` `text` |
| `syntax` | `keyword` `function` `macro` `type` `constant` `number` `string` `escape` `special` `variable` `property` `module` `annotation` `operator` `punctuation` `comment` |
| `ui` | `accent` `secondaryAccent` `cursor` `selection` `cursorLine` `search` `match` `title` |
| `status` | `error` `errorMuted` `warning` `info` `hint` `success` `diffAdded` `diffDeleted` `diffChanged` |
| `statusBar` | `background` `foreground` `dim` |
| `decorative` | `rainbow` (6) |
| `terminal` | `ansi` (16) |

There is also `isLight`, `named` (the same colours as one flat table, for
formats that look colours up by name) and `native` (the theme's own vocabulary,
for when a colour has no portable equivalent).

`config.orchard.<port>.palette` is the palette one program resolved to, and
`config.orchard.catalogue` lists every theme with its source, flavours and
accents. The flake also exposes `<flake>.palettes.<theme>.<flavor>`.

## Themes

| theme | flavours | accents | from |
| --- | --- | --- | --- |
| `adwaita` | dark, light | blue, teal, green, yellow, orange, red, purple, violet, brown | [helix's Adwaita themes](https://github.com/helix-editor/helix/tree/master/runtime/themes) |
| `ashen` | ashen | blaze, glow, golden, smolder, ember, flame, glowing, teal, brown | [ficd/ashen.nvim](https://codeberg.org/ficd/ashen.nvim) |
| `catppuccin` | latte, frappe, macchiato, mocha | the usual fourteen | [catppuccin/palette](https://github.com/catppuccin/palette) |
| `evergarden` | fall, spring, winter, summer, lunar | the twelve hues | [evergarden/nvim](https://codeberg.org/evergarden/nvim) |
| `gruvbox` | dark, dark-hard, dark-soft, light, light-hard, light-soft | red, orange, yellow, green, aqua, blue, purple | [morhetz/gruvbox](https://github.com/morhetz/gruvbox) |
| `gruvbox-material` | the same six | the same seven | [sainnhe/gruvbox-material](https://github.com/sainnhe/gruvbox-material) |
| `luna` | luna | blue, orange, purple, green, amber, red, yellow | [WTFox/luna.nvim](https://github.com/WTFox/luna.nvim) |
| `onedark` | dark, light | red, orange, yellow, green, aqua, blue, purple | [joshdick/onedark.vim](https://github.com/joshdick/onedark.vim) |
| `zed` | dark, light | red, orange, yellow, green, aqua, blue, purple | [Zed's One](https://github.com/zed-industries/zed/blob/main/assets/themes/one/one.json) |

Palettes are copied into the repo rather than fetched, so evaluation stays pure.

## Upstream themes

Some programs ship the theme you asked for already. Where that happens, Orchard
would rather use theirs than generate its own: they usually cover more syntax
scopes and stay in step with the program. Those ports take a `source`:

- `auto` (the default) uses the program's own theme when it exists and can do
  what you asked for, and generates one otherwise.
- `upstream` insists on the program's own theme and fails if there isn't one.
- `generated` always builds from the palette.

`resolvedSource` tells you which one `auto` picked. A built-in usually cannot
follow a custom accent, so choosing one falls back to a generated theme. Helix
can be wrapped to drop its background; micro cannot, so a transparent micro is
generated.

## Adding a theme

Drop a `themes/<name>/default.nix` in:

```nix
{ lib, ... }:
{
  description = "Example theme";
  source = "https://example.com/theme";

  palettes = import ./palettes.nix;
  defaultFlavor = "dark";
  lightFlavors = [ "light" ];

  accents = { blue = "blue"; };
  defaultAccent = "blue";

  integrations.helix = {
    kind = "builtin";
    name = flavor: "example-${flavor}";
  };

  colours = { raw, isLight, flavor }: raw // { };
  roles = p: { keyword = p.purple; };

  ports.yazi = { p, ... }: data: data;
}
```

`colours` maps the theme's own names onto Orchard's. `roles` changes which of
them syntax and interface elements use. `integrations` names a theme the program
already ships. A `ports.<name>` hook touches up one program.

## Adding a port

Drop a `ports/<program>.nix` in. You describe the program's theme once and it
works for every theme:

```nix
{ lib, render }:
let
  theme = p: {
    background = p.surface.background;
    foreground = p.surface.text;
  };
in
{
  description = "Example program";

  options.italics = lib.mkOption { };
  theme = { p, ... }: theme p;

  hjem = {
    when = { config, ... }: config.rum.programs.example.enable;
    config = { data, ... }: { rum.programs.example.settings = data; };
  };

  home = { data, ... }: { programs.example.settings = data; };
}
```

Use `when` to follow the program's own enabled state, or leave it out to always
apply. Leave out `theme` if the port writes no colours of its own.

Generated settings go in as low-priority defaults, so you can override a single
one without turning the port off.

## Checks

```sh
nix flake check
```

That covers all palettes, ports, theme flavours, the selector, all three module types, and the real home-manager and hjem configs.
