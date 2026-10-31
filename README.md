# Orchard

A shared theme system for Nix. Pick a theme once and every supported program you
already use gets themed to match. Orchard prefers work maintained by the theme
or application authors and uses its semantic palette renderer only as a
fallback.

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
    ghostty.enable = false;   # opt out of one application port
    btop.theme = "gruvbox";   # or theme one program differently
    yazi.transparent = false; # or keep one opaque

    # Session-wide toolkit integrations are always explicit.
    gtk.enable = true;
    qt.enable = true;
  };
}
```

Pick a flavour or accent the theme does not have and you get told so, with the list of the ones it does:

```
orchard: macchiato is not a flavor of gruvbox. Choose one of dark, dark-hard,
dark-soft, light, light-hard, light-soft
```

## Which programs get themed

By default Orchard themes supported applications you have already enabled, plus
the ones that only need a file dropped somewhere if they are in your packages.
That is `autoEnable`. Turn it off and no application port is themed until you
ask:

```nix
orchard.autoEnable = false;
orchard.helix.enable = true;
```

Either way, `orchard.<port>.enable` decides a single program.

Broad integrations are never auto-enabled. GTK, Qt and the Linux virtual
console require their own `enable = true` even while `autoEnable` is on.

These are the programs Orchard knows:

`alacritty` `bat` `btop` `console` `delta` `eza` `fish` `foot` `fuzzel` `fzf` `gtk`
`ghostty` `glamour` `helix` `imv` `kitty` `lazygit` `mako` `micro` `nushell` `rmpc`
`qt` `starship` `tmux` `tofi` `vivid` `wezterm` `yazi` `zathura` `zellij`
`zsh-syntax-highlighting`

Most work under hjem and home-manager. `gtk`, `qt`, `lazygit`, `mako` and
`zathura` are home-manager only, and the Linux virtual `console` is NixOS only.

`helix`, `yazi`, `fzf` and `micro` can skip their background, and follow
`orchard.transparent` unless you set their own.

## GTK and Qt

Toolkit theming affects an entire graphical session, so it is opt-in and never
generated from palette colours. Enable it directly alongside the default
module:

```nix
{
  orchard = {
    enable = true;
    theme = "catppuccin";
    gtk.enable = true;
    qt.enable = true;
  };
}
```

Alternatively import one self-contained Home Manager module instead of the
default module. `desktop` enables both integrations; `gtk` and `qt` enable one:

```nix
imports = [ inputs.orchard.homeModules.desktop ];
```

Catppuccin uses its official GTK and Kvantum projects from the pinned nixpkgs.
Adwaita uses GTK's native theme and the Adwaita Qt integration on Linux. Other
themes currently fail clearly when a toolkit integration is requested; Orchard
does not invent GTK CSS or Kvantum assets for them. Catppuccin Qt is likewise
Linux-only because the Kvantum engine is not available on Darwin.

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
| `syntax` | `keyword` `function` `macro` `type` `constant` `number` `string` `escape` `escapeAlt` `inlineCode` `special` `variable` `property` `module` `annotation` `operator` `punctuation` `comment` |
| `ui` | `accent` `secondaryAccent` `cursor` `selection` `cursorLine` `search` `match` `title` |
| `status` | `error` `errorMuted` `warning` `info` `hint` `success` `diffAdded` `diffDeleted` `diffChanged` |
| `statusBar` | `background` `foreground` `inactive` `dim`, plus `mode.{foreground,normal,insert,select}` |
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
| `rose-pine` | main, moon, dawn | love, gold, rose, pine, foam, iris | [rose-pine/palette](https://github.com/rose-pine/palette) |
| `matugen` | dark, light | primary, secondary, tertiary and the eight hues | generated from `orchard.matugen.image` by [matugen](https://github.com/InioX/matugen) |
| `zed` | dark, light | red, orange, yellow, green, aqua, blue, purple | [Zed's One](https://github.com/zed-industries/zed/blob/main/assets/themes/one/one.json) |

Palettes are copied into the repo rather than fetched, so evaluation stays pure.

`matugen` is the exception: its palettes are Material 3 schemes generated
from an image at build time, so choosing it imports from a derivation.

```nix
orchard = {
  theme = "matugen";
  flavour = "dark";
  matugen = {
    image = ./wallpaper.png;
    type = "scheme-tonal-spot"; # any Material 3 variant
    contrast = 0;               # -1 to 1
  };
};
```

The twelve surfaces come from Material's tonal surfaces and outlines, and
the twelve hues are the usual ones harmonized toward the image's source
colour. Every Material role (`primary`, `on_surface_variant`,
`surface_container_high`, ...) stays available under `palette.native`.

## Colours from the wallpaper

`orchard.wallpaper` runs a user service that reads what sway is actually
showing and keeps a few files coloured to match:

```nix
orchard.wallpaper = {
  enable = true;
  target = "sway-session.target";
  fuzzel.enable = true;
  swaynag.enable = true;
};
```

```
# sway config, after the bar blocks
${config.orchard.wallpaper.targets."sway.conf".fallback}
include ${config.orchard.wallpaper.targets."sway.conf".path}
```

Sway never reports the background, so the service reads each running
swaybg's own arguments and follows it through a pidfd, re-theming when
`output * bg` respawns it. The image is laid out as swaybg lays it out on
every output (fill crops, fit letterboxes in the fallback colour, center and
tile do what they say), and only what is visible counts, weighted by each
output's pixels.

From those pixels, in OKLab with Ottosson's toe lightness:

- **Greys** follow Catppuccin's lightness steps. Each step leans toward the
  pixels of the wallpaper near its own lightness, so shadows tint the base
  and highlights tint the text. The lean is capped where grey stops reading
  as grey (about 0.026 chroma, less for warm hues and near white), and a
  balanced or grey picture gives plain greys.
- **The accent** is the wallpaper's own colour. Clusters from a deterministic
  weighted k-means are scored in the manner of material-color-utilities,
  except that area counts by how coloured it is, so skin tones and pale
  washes do not outvote the subject. Greys, near-black and slivers never win.
  A wallpaper with no colour keeps the theme's accent.
- **Twelve hues** keep their names (red stays red). Each turns toward the
  accent by half the gap, capped per hue and fading with distance, and
  neighbours are kept apart. Chroma follows how vivid the wallpaper is, and
  green sits lighter than red for red-green colour blindness.
- **Contrast** is checked on the final hex, with WCAG 2 and APCA: text 7:1,
  subtext 5.5 and 4.5, comments 3.5, every hue and the accent 4.5 on the base
  and 3:1 on the panels.

A template names colours as `config.orchard.palette` does, written
`{{surface.background}}` for `#rrggbb` or `{{ui.accent|bare}}` for `rrggbb`.
Add your own under `orchard.wallpaper.targets.<file>`, with an optional
`reload` command. Each target's `fallback` is the template filled from the
configured theme. The current palette is also kept as JSON at
`orchard.wallpaper.palette`. To try a picture by hand:

```sh
orchard-wallpaper palette --image wall.png --mode fill --size 3024x1964
```

## Upstream themes

Themes can have several providers. Orchard tries compatible providers in this
order: an official theme-project integration, a theme built into the target
application, then a community integration. Only then may a normal application
port use its generated renderer. Providers can carry pinned packages and files,
not merely a built-in theme name.

Ports with a generated fallback take a `source`:

- `prefer-upstream` (the default) uses the best compatible provider and
  generates a theme only when there is none.
- `require-upstream` insists on a compatible provider and fails without one.
- `generated` always builds from the palette.

`auto` and `upstream` remain accepted as compatibility spellings for
`prefer-upstream` and `require-upstream`.

`resolvedSource` reports `official`, `builtin`, `community`, `generated`, or
`unavailable`. A built-in usually cannot follow a custom per-port accent, so
choosing one falls back to a generated theme. Helix can wrap a built-in to drop
its background; micro cannot, so transparent micro is generated. Provider-only
ports such as GTK and Qt do not offer `generated` at all.

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

  integrations = {
    helix = {
      kind = "builtin";
      name = flavor: "example-${flavor}";
    };

    gtk.providers = [
      {
        kind = "official";
        capabilities.accent = true;
        resolve = { pkgs, flavor, accent, ... }: {
          name = "example-${flavor}-${accent}";
          package = pkgs.example-gtk.override { inherit flavor accent; };
        };
      }
    ];
  };

  colours = { raw, isLight, flavor }: raw // { };
  roles = p: { keyword = p.purple; };

  ports.yazi = { p, ... }: data: data;
}
```

`colours` maps the theme's own names onto Orchard's. `roles` changes which of
them syntax and interface elements use. An integration may be a built-in name or
an ordered set of official, built-in and community providers. A provider's
`resolve` result may include a package, file and adapter-specific metadata. A
`ports.<name>` hook touches up one generated program theme.

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

  # Use this for session-wide or system-wide integrations.
  activation = "explicit";

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
apply. Set `activation = "explicit"` when global auto-enable would be too broad.
Leave out `theme` if the port writes no colours of its own; also set
`generated = false` for a provider-only integration.

Generated settings go in as low-priority defaults, so you can override a single
one without turning the port off.

## Checks

```sh
nix flake check
```

That covers all palettes, ports, theme flavours, the selector, all three module types, and the real home-manager and hjem configs.
