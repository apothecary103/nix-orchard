{ lib, render }:

let
  # catppuccin/foot. foot takes bare RRGGBB, and its selection background is the
  # overlay mixed a third of the way into the base rather than a palette step.
  theme =
    p:
    let
      c = render.noHash;

      slots =
        prefix: offset:
        lib.listToAttrs (
          lib.imap0 (i: colour: lib.nameValuePair "${prefix}${toString i}" (c colour)) (
            lib.sublist offset 8 p.terminal.ansi
          )
        );
    in
    {
      colors = {
        foreground = c p.surface.text;
        background = c p.surface.background;

        selection-foreground = c p.surface.text;
        selection-background = c (
          render.mix {
            colour = p.surface.neutral5;
            over = p.surface.background;
          } 0.3
        );

        search-box-no-match = "${c p.surface.shadow} ${c p.status.error}";
        search-box-match = "${c p.surface.text} ${c p.surface.neutral0}";

        jump-labels = "${c p.surface.shadow} ${c p.hue.orange}";
        urls = c p.hue.blue;

        "16" = c p.hue.orange;
        "17" = c p.hue.cherry;
      }
      // slots "regular" 0
      // slots "bright" 8;

      cursor.color = "${
        c (if p.isLight then p.surface.background else p.surface.shadow)
      } ${c p.ui.cursor}";
    };
in
{
  description = "foot";

  theme = { p, ... }: theme p;

  hjem = {
    when = { config, ... }: config.rum.programs.foot.enable;

    config =
      { data, ... }:
      {
        rum.programs.foot.settings = lib.mapAttrs (_: lib.mapAttrs (_: lib.mkDefault)) data;
      };
  };

  home = {
    when = { config, ... }: config.programs.foot.enable;

    config =
      { data, ... }:
      {
        programs.foot.settings = lib.mapAttrs (_: lib.mapAttrs (_: lib.mkDefault)) data;
      };
  };
}
