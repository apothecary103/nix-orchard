# ashen.yazi, verbatim. Two things it does that a derived flavor would not: the
# cwd is orange rather than the accent, and it leaves `[icon]` alone entirely,
# so yazi's own icon set — colours included — stays exactly as it ships. That is
# why the directory glyph should not be wearing the accent.
{
  p,
  lib,
  data,
}:

let
  raw = p.raw;
in
removeAttrs data [ "icon" ]
// {
  # Whatever the port decided about transparency, kept as it is.
  inherit (data) app;

  mgr = {
    cwd = {
      fg = raw.orange_glow;
      bold = true;
    };

    find_keyword = {
      fg = raw.blue;
      bold = true;
      italic = true;
      underline = true;
    };
    find_position = {
      fg = raw.blue;
      bg = "reset";
      bold = true;
      italic = true;
    };

    marker_copied = {
      fg = raw.green;
      bg = raw.green;
    };
    marker_cut = {
      fg = raw.red_flame;
      bg = raw.red_flame;
    };
    marker_marked = {
      fg = raw.orange_golden;
      bg = raw.orange_golden;
    };
    marker_selected = {
      fg = raw.orange_blaze;
      bg = raw.orange_blaze;
    };

    count_copied = {
      fg = raw.background;
      bg = raw.green;
    };
    count_cut = {
      fg = raw.background;
      bg = raw.red_flame;
    };
    count_selected = {
      fg = raw.background;
      bg = raw.orange_blaze;
    };

    border_symbol = "│";
    border_style.fg = raw.g_4;
  };

  tabs = {
    active = {
      fg = raw.background;
      bg = raw.g_3;
      bold = true;
    };
    inactive = {
      fg = raw.g_3;
      bg = raw.g_9;
    };
  };

  mode = {
    normal_main = {
      fg = raw.background;
      bg = raw.g_3;
      bold = true;
    };
    normal_alt = {
      fg = raw.g_3;
      bg = raw.g_9;
    };
    select_main = {
      fg = raw.background;
      bg = raw.red_soft;
      bold = true;
    };
    select_alt = {
      fg = raw.red_soft;
      bg = raw.g_9;
    };
    unset_main = {
      fg = raw.background;
      bg = raw.orange_glow;
      bold = true;
    };
    unset_alt = {
      fg = raw.orange_glow;
      bg = raw.g_9;
    };
  };

  status = {
    sep_left = {
      open = "";
      close = "";
    };
    sep_right = {
      open = "";
      close = "";
    };

    progress_label = {
      fg = raw.background;
      bold = true;
    };
    progress_normal = {
      fg = raw.orange_blaze;
      bg = raw.g_8;
    };
    progress_error = {
      fg = raw.red_flame;
      bg = raw.g_8;
    };

    perm_sep = {
      fg = raw.g_5;
      bold = true;
    };
    perm_type.fg = raw.red_ember;
    perm_read = {
      fg = raw.g_2;
      bold = true;
    };
    perm_write = {
      fg = raw.orange_blaze;
      bold = true;
    };
    perm_exec = {
      fg = raw.red_ember;
      bold = true;
    };
  };

  input = {
    border.fg = raw.red_ember;
    title = { };
    value = { };
    selected.reversed = true;
  };

  pick = {
    border.fg = raw.orange_blaze;
    active = {
      fg = raw.red_glowing;
      bold = true;
    };
    inactive = { };
  };

  confirm = {
    border.fg = raw.orange_blaze;
    title = { };
    body = { };
    list = { };
    btn_yes.reversed = true;
    btn_no = { };
  };

  cmp.border.fg = raw.red_ember;

  tasks = {
    border.fg = raw.orange_blaze;
    title = { };
    hovered = {
      fg = raw.g_2;
      underline = true;
    };
  };

  which = {
    mask.bg = raw.g_9;
    cand.fg = raw.orange_smolder;
    rest.fg = raw.g_3;
    desc.fg = raw.red_glowing;
    separator = "  ";
    separator_style.fg = raw.red_ember;
  };

  help = {
    on.fg = raw.orange_glow;
    run.fg = raw.red_glowing;
    desc.fg = raw.g_2;
    hovered = {
      reversed = true;
      bold = true;
    };
    footer = {
      fg = raw.g_1;
      bg = raw.background;
    };
  };

  notify = {
    title_info.fg = raw.g_2;
    title_warn.fg = raw.orange_golden;
    title_error.fg = raw.red_flame;
  };

  spot = {
    border.fg = raw.orange_blaze;
    title = { };
    tbl_cell = {
      fg = raw.g_2;
      reversed = true;
    };
    tbl_col = { };
  };

  filetype.rules = [
    {
      mime = "image/*";
      fg = raw.orange_smolder;
    }
    {
      mime = "{audio,video}/*";
      fg = raw.orange_glow;
    }
    {
      mime = "application/{zip,rar,7z*,tar,gzip,xz,zstd,bzip*,lzma,compress,archive,cpio,arj,xar,ms-cab*}";
      fg = raw.red_glowing;
    }
    {
      mime = "application/{pdf,doc,rtf}";
      fg = raw.orange_blaze;
    }
    {
      url = "*";
      fg = raw.g_2;
    }
    {
      url = "*/";
      fg = raw.red_ember;
    }
  ];
}
