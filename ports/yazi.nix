{ lib, render }:

let
  # Follows catppuccin/yazi's flavor.toml node for node, including the icon
  # section — the part a palette-derived theme usually drops and the part you
  # actually look at.
  theme = p: {
    app.overall.bg = p.surface.background;

    mgr = {
      cwd.fg = p.hue.aqua;

      find_keyword = {
        fg = p.hue.yellow;
        italic = true;
      };
      find_position = {
        fg = p.hue.pink;
        bg = "reset";
        italic = true;
      };

      marker_copied = {
        fg = p.status.success;
        bg = p.status.success;
      };
      marker_cut = {
        fg = p.status.error;
        bg = p.status.error;
      };
      marker_marked = {
        fg = p.hue.aqua;
        bg = p.hue.aqua;
      };
      marker_selected = {
        fg = p.ui.accent;
        bg = p.ui.accent;
      };

      count_copied = {
        fg = p.surface.background;
        bg = p.status.success;
      };
      count_cut = {
        fg = p.surface.background;
        bg = p.status.error;
      };
      count_selected = {
        fg = p.surface.background;
        bg = p.ui.accent;
      };

      border_symbol = "│";
      border_style.fg = p.surface.neutral4;
    };

    tabs = {
      active = {
        fg = p.surface.background;
        bg = p.surface.text;
        bold = true;
      };
      inactive = {
        fg = p.surface.text;
        bg = p.surface.neutral1;
      };
    };

    mode = {
      normal_main = {
        fg = p.surface.background;
        bg = p.ui.accent;
        bold = true;
      };
      normal_alt = {
        fg = p.ui.accent;
        bg = p.surface.neutral0;
      };
      select_main = {
        fg = p.surface.background;
        bg = p.status.success;
        bold = true;
      };
      select_alt = {
        fg = p.status.success;
        bg = p.surface.neutral0;
      };
      unset_main = {
        fg = p.surface.background;
        bg = p.hue.cherry;
        bold = true;
      };
      unset_alt = {
        fg = p.hue.cherry;
        bg = p.surface.neutral0;
      };
    };

    indicator = {
      parent = {
        fg = p.surface.background;
        bg = p.surface.text;
      };
      current = {
        fg = p.surface.background;
        bg = p.ui.accent;
      };
      preview = {
        fg = p.surface.background;
        bg = p.surface.text;
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
        fg = p.surface.text;
        bold = true;
      };
      progress_normal = {
        fg = p.status.success;
        bg = p.surface.neutral1;
      };
      progress_error = {
        fg = p.status.warning;
        bg = p.status.error;
      };

      perm_type.fg = p.hue.blue;
      perm_read.fg = p.hue.yellow;
      perm_write.fg = p.hue.red;
      perm_exec.fg = p.hue.green;
      perm_sep.fg = p.surface.neutral4;
    };

    input = {
      border.fg = p.ui.accent;
      title = { };
      value = { };
      selected.reversed = true;
    };

    pick = {
      border.fg = p.ui.accent;
      active.fg = p.hue.pink;
      inactive = { };
    };

    confirm = {
      border.fg = p.ui.accent;
      title.fg = p.ui.accent;
      body = { };
      list = { };
      btn_yes.reversed = true;
      btn_no = { };
    };

    cmp.border.fg = p.ui.accent;

    tasks = {
      border.fg = p.ui.accent;
      title = { };
      hovered = {
        fg = p.hue.pink;
        bold = true;
      };
    };

    which = {
      mask.bg = p.surface.neutral0;
      cand.fg = p.hue.aqua;
      rest.fg = p.surface.neutral5;
      desc.fg = p.hue.pink;
      separator = "  ";
      separator_style.fg = p.surface.neutral2;
    };

    help = {
      on.fg = p.hue.aqua;
      run.fg = p.hue.pink;
      desc.fg = p.surface.neutral5;
      hovered = {
        bg = p.surface.neutral2;
        bold = true;
      };
      footer = {
        fg = p.surface.text;
        bg = p.surface.neutral1;
      };
    };

    notify = {
      title_info.fg = p.hue.aqua;
      title_warn.fg = p.status.warning;
      title_error.fg = p.status.error;
    };

    filetype.rules = [
      {
        mime = "image/*";
        fg = p.hue.yellow;
      }
      {
        mime = "{audio,video}/*";
        fg = p.hue.pink;
      }
      {
        mime = "application/{zip,rar,7z*,tar,gzip,xz,zstd,bzip*,lzma,compress,archive,cpio,arj,xar,ms-cab*}";
        fg = p.hue.red;
      }
      {
        mime = "application/{pdf,doc,rtf}";
        fg = p.hue.skye;
      }
      {
        mime = "vfs/{absent,stale}";
        fg = p.surface.neutral1;
      }
      {
        url = "*";
        is = "orphan";
        bg = p.hue.red;
      }
      {
        url = "*";
        is = "exec";
        fg = p.hue.green;
      }
      {
        url = "*";
        is = "dummy";
        bg = p.hue.red;
      }
      {
        url = "*/";
        is = "dummy";
        bg = p.hue.red;
      }
      {
        url = "*/";
        fg = p.ui.accent;
      }
    ];

    spot = {
      border.fg = p.ui.accent;
      title.fg = p.ui.accent;
      tbl_cell = {
        fg = p.ui.accent;
        reversed = true;
      };
      tbl_col.bold = true;
    };

    # Prepended rather than assigned: a bare `dirs`/`conds` replaces yazi's
    # own set outright, and its several hundred `files` and `exts` entries are
    # worth far more than the handful an accent could recolour.
    icon = {
      prepend_dirs = [
        {
          name = ".config";
          text = "";
          fg = p.ui.accent;
        }
        {
          name = ".git";
          text = "";
          fg = p.ui.accent;
        }
        {
          name = ".github";
          text = "";
          fg = p.ui.accent;
        }
        {
          name = ".npm";
          text = "";
          fg = p.ui.accent;
        }
        {
          name = "Desktop";
          text = "";
          fg = p.ui.accent;
        }
        {
          name = "Development";
          text = "";
          fg = p.ui.accent;
        }
        {
          name = "Documents";
          text = "";
          fg = p.ui.accent;
        }
        {
          name = "Downloads";
          text = "";
          fg = p.ui.accent;
        }
        {
          name = "Library";
          text = "";
          fg = p.ui.accent;
        }
        {
          name = "Movies";
          text = "";
          fg = p.ui.accent;
        }
        {
          name = "Music";
          text = "";
          fg = p.ui.accent;
        }
        {
          name = "Pictures";
          text = "";
          fg = p.ui.accent;
        }
        {
          name = "Public";
          text = "";
          fg = p.ui.accent;
        }
        {
          name = "Videos";
          text = "";
          fg = p.ui.accent;
        }
      ];

      prepend_conds = [
        {
          "if" = "orphan";
          text = "";
          fg = p.surface.text;
        }
        {
          "if" = "link";
          text = "";
          fg = p.surface.textDim;
        }
        {
          "if" = "block";
          text = "";
          fg = p.hue.yellow;
        }
        {
          "if" = "char";
          text = "";
          fg = p.hue.yellow;
        }
        {
          "if" = "fifo";
          text = "";
          fg = p.hue.yellow;
        }
        {
          "if" = "sock";
          text = "";
          fg = p.hue.yellow;
        }
        {
          "if" = "sticky";
          text = "";
          fg = p.hue.yellow;
        }
        {
          "if" = "dummy";
          text = "";
          fg = p.hue.red;
        }
        {
          "if" = "dir";
          text = "";
          fg = p.ui.accent;
        }
        {
          "if" = "exec";
          text = "";
          fg = p.hue.green;
        }
        {
          "if" = "!dir";
          text = "";
          fg = p.surface.text;
        }
      ];
    };
  };

  # A flavor rather than theme.toml, which yazi reserves for the user's own
  # overrides: it layers preset < flavor < theme.toml. A flavor picks up the
  # tmTheme sitting beside it, so the file preview matches the rest of the UI
  # without pointing `syntect_theme` anywhere.
  files = pkgs: p: data: name: {
    "yazi/flavors/${name}.yazi/flavor.toml".source =
      (pkgs.formats.toml { }).generate "flavor.toml"
        data;

    "yazi/flavors/${name}.yazi/tmtheme.xml".text = render.mkTmTheme { inherit name p; };
  };
in
{
  description = "yazi";

  transparency = true;

  # yazi's own preset leaves `app.overall` an empty table, which is what makes
  # it transparent out of the box — painting the base over it is what this port
  # adds. So the transparent case drops the key rather than setting it to
  # "reset": a reset background is still a background, and ratatui fills every
  # cell with it.
  theme =
    { p, cfg, ... }:
    let
      full = theme p;
    in
    if cfg.transparent then full // { app.overall = { }; } else full;

  hjem = {
    when = { config, ... }: config.rum.programs.yazi.enable;

    config =
      {
        pkgs,
        p,
        data,
        name,
        ...
      }:
      {
        xdg.config.files = files pkgs p data name;

        rum.programs.yazi.theme.flavor = {
          dark = lib.mkDefault name;
          light = lib.mkDefault name;
        };
      };
  };

  home = {
    when = { config, ... }: config.programs.yazi.enable;

    config =
      {
        pkgs,
        p,
        data,
        name,
        ...
      }:
      {
        xdg.configFile = files pkgs p data name;

        programs.yazi.theme.flavor = {
          dark = lib.mkDefault name;
          light = lib.mkDefault name;
        };
      };
  };
}
