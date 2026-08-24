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
            lib.sublist offset 8 p.ansi
          )
        );
    in
    {
      colors = {
        foreground = c p.text;
        background = c p.base;

        selection-foreground = c p.text;
        selection-background = c (
          render.mix {
            colour = p.overlay2;
            over = p.base;
          } 0.3
        );

        search-box-no-match = "${c p.crust} ${c p.error}";
        search-box-match = "${c p.text} ${c p.surface0}";

        jump-labels = "${c p.crust} ${c p.orange}";
        urls = c p.blue;

        "16" = c p.orange;
        "17" = c p.cherry;
      }
      // slots "regular" 0
      // slots "bright" 8;

      cursor.color = "${c (if p.isLight then p.base else p.crust)} ${c p.cursor}";
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
