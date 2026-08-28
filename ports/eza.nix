{ ... }:

let
  # catppuccin/eza.
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
        normal = fg p.surface.text;
        directory = fg p.ui.accent;
        symlink = fg p.hue.blue;
        pipe = fg p.surface.textMuted;
        block_device = fg p.status.errorMuted;
        char_device = fg p.status.errorMuted;
        socket = fg p.surface.textMuted;
        special = fg p.hue.purple;
        executable = fg p.hue.green;
        mount_point = fg p.hue.aqua;
      };

      perms = {
        user_read = bold p.hue.red;
        user_write = bold p.hue.yellow;
        user_execute_file = bold p.hue.green;
        user_execute_other = bold p.hue.green;
        group_read = fg p.hue.red;
        group_write = fg p.hue.yellow;
        group_execute = fg p.hue.green;
        other_read = fg p.hue.red;
        other_write = fg p.hue.yellow;
        other_execute = fg p.hue.green;
        special_user_file = fg p.hue.purple;
        special_other = fg p.surface.neutral4;
        attribute = fg p.surface.neutral5;
      };

      size = {
        major = fg p.surface.textDim;
        minor = fg p.hue.skye;
        number_byte = fg p.surface.textMuted;
        number_kilo = fg p.surface.textDim;
        number_mega = fg p.hue.blue;
        number_giga = fg p.hue.purple;
        number_huge = fg p.hue.purple;
        unit_byte = fg p.surface.textDim;
        unit_kilo = fg p.hue.skye;
        unit_mega = fg p.hue.purple;
        unit_giga = fg p.hue.purple;
        unit_huge = fg p.hue.aqua;
      };

      users = {
        user_you = fg p.surface.text;
        user_root = fg p.hue.red;
        user_other = fg p.status.errorMuted;
        group_yours = fg p.surface.textDim;
        group_other = fg p.surface.neutral5;
        group_root = fg p.hue.red;
      };

      links = {
        normal = fg p.hue.blue;
        multi_link_file = fg p.hue.blue;
      };

      git = {
        new = fg p.hue.green;
        modified = fg p.hue.yellow;
        deleted = fg p.status.errorMuted;
        renamed = fg p.hue.aqua;
        typechange = fg p.hue.pink;
        ignored = fg p.surface.neutral4;
        conflicted = fg p.hue.orange;
      };

      git_repo = {
        branch_main = fg p.surface.textDim;
        branch_other = fg p.hue.purple;
        git_clean = fg p.hue.green;
        git_dirty = fg p.status.errorMuted;
      };

      security_context = {
        colon = fg p.surface.neutral3;
        user = fg p.surface.neutral4;
        role = fg p.hue.purple;
        typ = fg p.surface.neutral2;
        range = fg p.hue.purple;
      };

      file_type = {
        image = fg p.hue.yellow;
        video = fg p.hue.red;
        music = fg p.hue.green;
        lossless = fg p.hue.aqua;
        crypto = fg p.surface.neutral4;
        document = fg p.surface.text;
        compressed = fg p.hue.pink;
        temp = fg p.status.errorMuted;
        compiled = fg p.hue.snow;
        source = fg p.hue.blue;
      };

      punctuation = fg p.surface.neutral3;
      date = fg p.hue.yellow;
      inode = fg p.surface.textDim;
      blocks = fg p.surface.neutral3;
      header = fg p.surface.text;
      octal = fg p.hue.aqua;
      flags = fg p.hue.purple;

      symlink_path = fg p.hue.skye;
      control_char = fg p.hue.snow;
      broken_symlink = fg p.hue.red;
      broken_path_overlay = fg p.surface.neutral2;
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
