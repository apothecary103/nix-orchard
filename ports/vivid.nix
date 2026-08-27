{ lib, render }:

let
  # vivid's themes are hex without the '#', and every filetype group resolves
  # through the named colours below rather than repeating literals.
  theme = p: {
    colors = lib.mapAttrs (_: render.noHash) p.named;

    core = {
      regular_file.foreground = "text";
      directory = {
        foreground = "blue";
        font-style = "bold";
      };
      symlink.foreground = "blue";
      broken_symlink.foreground = "error";
      executable_file = {
        foreground = "green";
        font-style = "bold";
      };
      fifo.foreground = "subtext1";
      socket.foreground = "subtext1";
      character_device.foreground = "orange";
      block_device.foreground = "orange";
      normal_text.foreground = "text";

      sticky = {
        foreground = "base";
        background = "blue";
      };
      other_writable = {
        foreground = "base";
        background = "aqua";
      };
      sticky_other_writable = {
        foreground = "base";
        background = "purple";
      };

      setuid = {
        foreground = "base";
        background = "error";
      };
      setgid = {
        foreground = "base";
        background = "warning";
      };
    };

    text.special.foreground = "special";
    markup.foreground = "title";
    programming.source.foreground = "blue";
    media.foreground = "pink";
    image.foreground = "yellow";
    video.foreground = "red";
    audio.foreground = "green";
    archive.foreground = "purple";
    document.foreground = "skye";
    unimportant.foreground = "overlay0";
  };

in
{
  # Only the theme file. LS_COLORS itself has to come out of `vivid generate
  # <name>` in the shell's own init, because baking it into a session variable
  # would mean reading a derivation at evaluation time.
  description = "LS_COLORS, via vivid";

  program = "vivid";

  # vivid bundles catppuccin, all six gruvbox contrasts and both onedark ends,
  # each with a curated filetype table far longer than the one below.
  integration = { };

  theme = { p, ... }: theme p;

  hjem =
    {
      pkgs,
      data,
      name,
      upstream,
      ...
    }:
    lib.mkIf (upstream == null) {
      xdg.config.files."vivid/themes/${name}.yml".source =
        (pkgs.formats.yaml { }).generate "vivid-theme.yml"
          data;
    };

  home =
    {
      pkgs,
      data,
      name,
      upstream,
      ...
    }:
    lib.mkIf (upstream == null) {
      xdg.configFile."vivid/themes/${name}.yml".source =
        (pkgs.formats.yaml { }).generate "vivid-theme.yml"
          data;
    };
}
