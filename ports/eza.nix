{ ... }:

let
  # catppuccin/eza. Directories take the accent, the permission triple is
  # red/yellow/green with the user row bold, and the size ramp climbs
  # subtext -> blue -> purple as the numbers grow.
  theme =
    p:
    let
      fg = colour: { foreground = colour; };
      bold = colour: {
        foreground = colour;
        is_bold = true;
      };
    in
    {
      colourful = true;

      filekinds = {
        normal = fg p.text;
        directory = fg p.accent;
        symlink = fg p.blue;
        pipe = fg p.subtext1;
        block_device = fg p.maroon;
        char_device = fg p.maroon;
        socket = fg p.subtext1;
        special = fg p.purple;
        executable = fg p.green;
        mount_point = fg p.aqua;
      };

      perms = {
        user_read = bold p.red;
        user_write = bold p.yellow;
        user_execute_file = bold p.green;
        user_execute_other = bold p.green;
        group_read = fg p.red;
        group_write = fg p.yellow;
        group_execute = fg p.green;
        other_read = fg p.red;
        other_write = fg p.yellow;
        other_execute = fg p.green;
        special_user_file = fg p.purple;
        special_other = fg p.overlay1;
        attribute = fg p.overlay2;
      };

      size = {
        major = fg p.subtext0;
        minor = fg p.skye;
        number_byte = fg p.subtext1;
        number_kilo = fg p.subtext0;
        number_mega = fg p.blue;
        number_giga = fg p.purple;
        number_huge = fg p.purple;
        unit_byte = fg p.subtext0;
        unit_kilo = fg p.skye;
        unit_mega = fg p.purple;
        unit_giga = fg p.purple;
        unit_huge = fg p.aqua;
      };

      users = {
        user_you = fg p.text;
        user_root = fg p.red;
        user_other = fg p.maroon;
        group_yours = fg p.subtext0;
        group_other = fg p.overlay2;
        group_root = fg p.red;
      };

      links = {
        normal = fg p.blue;
        multi_link_file = fg p.blue;
      };

      git = {
        new = fg p.green;
        modified = fg p.yellow;
        deleted = fg p.maroon;
        renamed = fg p.aqua;
        typechange = fg p.pink;
        ignored = fg p.overlay1;
        conflicted = fg p.orange;
      };

      git_repo = {
        branch_main = fg p.subtext0;
        branch_other = fg p.purple;
        git_clean = fg p.green;
        git_dirty = fg p.maroon;
      };

      security_context = {
        colon = fg p.overlay0;
        user = fg p.overlay1;
        role = fg p.purple;
        typ = fg p.surface2;
        range = fg p.purple;
      };

      file_type = {
        image = fg p.yellow;
        video = fg p.red;
        music = fg p.green;
        lossless = fg p.aqua;
        crypto = fg p.overlay1;
        document = fg p.text;
        compressed = fg p.pink;
        temp = fg p.maroon;
        compiled = fg p.snow;
        source = fg p.blue;
      };

      punctuation = fg p.overlay0;
      date = fg p.yellow;
      inode = fg p.subtext0;
      blocks = fg p.overlay0;
      header = fg p.text;
      octal = fg p.aqua;
      flags = fg p.purple;

      symlink_path = fg p.skye;
      control_char = fg p.snow;
      broken_symlink = fg p.red;
      broken_path_overlay = fg p.surface2;
    };
in
{
  description = "eza";

  program = "eza";

  theme = { p, ... }: theme p;

  hjem =
    { pkgs, data, ... }:
    {
      xdg.config.files."eza/theme.yml".source = (pkgs.formats.yaml { }).generate "eza-theme.yml" data;
    };

  home = {
    when = { config, ... }: config.programs.eza.enable;

    config =
      { pkgs, data, ... }:
      {
        xdg.configFile."eza/theme.yml".source = (pkgs.formats.yaml { }).generate "eza-theme.yml" data;
      };
  };
}
