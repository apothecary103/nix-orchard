{ lib, render }:

let
  # Follows catppuccin/yazi's flavor.toml node for node, including the icon
  # section — the part a palette-derived theme usually drops and the part you
  # actually look at.
  theme = p: {
    app.overall.bg = p.base;

    mgr = {
      cwd.fg = p.aqua;

      find_keyword = {
        fg = p.yellow;
        italic = true;
      };
      find_position = {
        fg = p.pink;
        bg = "reset";
        italic = true;
      };

      marker_copied = {
        fg = p.ok;
        bg = p.ok;
      };
      marker_cut = {
        fg = p.error;
        bg = p.error;
      };
      marker_marked = {
        fg = p.aqua;
        bg = p.aqua;
      };
      marker_selected = {
        fg = p.accent;
        bg = p.accent;
      };

      count_copied = {
        fg = p.base;
        bg = p.ok;
      };
      count_cut = {
        fg = p.base;
        bg = p.error;
      };
      count_selected = {
        fg = p.base;
        bg = p.accent;
      };

      border_symbol = "│";
      border_style.fg = p.overlay1;
    };

    tabs = {
      active = {
        fg = p.base;
        bg = p.text;
        bold = true;
      };
      inactive = {
        fg = p.text;
        bg = p.surface1;
      };
    };

    mode = {
      normal_main = {
        fg = p.base;
        bg = p.accent;
        bold = true;
      };
      normal_alt = {
        fg = p.accent;
        bg = p.surface0;
      };
      select_main = {
        fg = p.base;
        bg = p.ok;
        bold = true;
      };
      select_alt = {
        fg = p.ok;
        bg = p.surface0;
      };
      unset_main = {
        fg = p.base;
        bg = p.cherry;
        bold = true;
      };
      unset_alt = {
        fg = p.cherry;
        bg = p.surface0;
      };
    };

    indicator = {
      parent = {
        fg = p.base;
        bg = p.text;
      };
      current = {
        fg = p.base;
        bg = p.accent;
      };
      preview = {
        fg = p.base;
        bg = p.text;
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
        fg = p.text;
        bold = true;
      };
      progress_normal = {
        fg = p.ok;
        bg = p.surface1;
      };
      progress_error = {
        fg = p.warning;
        bg = p.error;
      };

      perm_type.fg = p.blue;
      perm_read.fg = p.yellow;
      perm_write.fg = p.red;
      perm_exec.fg = p.green;
      perm_sep.fg = p.overlay1;
    };

    input = {
      border.fg = p.accent;
      title = { };
      value = { };
      selected.reversed = true;
    };

    pick = {
      border.fg = p.accent;
      active.fg = p.pink;
      inactive = { };
    };

    confirm = {
      border.fg = p.accent;
      title.fg = p.accent;
      body = { };
      list = { };
      btn_yes.reversed = true;
      btn_no = { };
    };

    cmp.border.fg = p.accent;

    tasks = {
      border.fg = p.accent;
      title = { };
      hovered = {
        fg = p.pink;
        bold = true;
      };
    };

    which = {
      mask.bg = p.surface0;
      cand.fg = p.aqua;
      rest.fg = p.overlay2;
      desc.fg = p.pink;
      separator = "  ";
      separator_style.fg = p.surface2;
    };

    help = {
      on.fg = p.aqua;
      run.fg = p.pink;
      desc.fg = p.overlay2;
      hovered = {
        bg = p.surface2;
        bold = true;
      };
      footer = {
        fg = p.text;
        bg = p.surface1;
      };
    };

    notify = {
      title_info.fg = p.aqua;
      title_warn.fg = p.warning;
      title_error.fg = p.error;
    };

    filetype.rules = [
      {
        mime = "image/*";
        fg = p.yellow;
      }
      {
        mime = "{audio,video}/*";
        fg = p.pink;
      }
      {
        mime = "application/{zip,rar,7z*,tar,gzip,xz,zstd,bzip*,lzma,compress,archive,cpio,arj,xar,ms-cab*}";
        fg = p.red;
      }
      {
        mime = "application/{pdf,doc,rtf}";
        fg = p.skye;
      }
      {
        mime = "vfs/{absent,stale}";
        fg = p.surface1;
      }
      {
        url = "*";
        is = "orphan";
        bg = p.red;
      }
      {
        url = "*";
        is = "exec";
        fg = p.green;
      }
      {
        url = "*";
        is = "dummy";
        bg = p.red;
      }
      {
        url = "*/";
        is = "dummy";
        bg = p.red;
      }
      {
        url = "*/";
        fg = p.accent;
      }
    ];

    spot = {
      border.fg = p.accent;
      title.fg = p.accent;
      tbl_cell = {
        fg = p.accent;
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
          fg = p.accent;
        }
        {
          name = ".git";
          text = "";
          fg = p.accent;
        }
        {
          name = ".github";
          text = "";
          fg = p.accent;
        }
        {
          name = ".npm";
          text = "";
          fg = p.accent;
        }
        {
          name = "Desktop";
          text = "";
          fg = p.accent;
        }
        {
          name = "Development";
          text = "";
          fg = p.accent;
        }
        {
          name = "Documents";
          text = "";
          fg = p.accent;
        }
        {
          name = "Downloads";
          text = "";
          fg = p.accent;
        }
        {
          name = "Library";
          text = "";
          fg = p.accent;
        }
        {
          name = "Movies";
          text = "";
          fg = p.accent;
        }
        {
          name = "Music";
          text = "";
          fg = p.accent;
        }
        {
          name = "Pictures";
          text = "";
          fg = p.accent;
        }
        {
          name = "Public";
          text = "";
          fg = p.accent;
        }
        {
          name = "Videos";
          text = "";
          fg = p.accent;
        }
      ];

      prepend_conds = [
        {
          "if" = "orphan";
          text = "";
          fg = p.text;
        }
        {
          "if" = "link";
          text = "";
          fg = p.subtext0;
        }
        {
          "if" = "block";
          text = "";
          fg = p.yellow;
        }
        {
          "if" = "char";
          text = "";
          fg = p.yellow;
        }
        {
          "if" = "fifo";
          text = "";
          fg = p.yellow;
        }
        {
          "if" = "sock";
          text = "";
          fg = p.yellow;
        }
        {
          "if" = "sticky";
          text = "";
          fg = p.yellow;
        }
        {
          "if" = "dummy";
          text = "";
          fg = p.red;
        }
        {
          "if" = "dir";
          text = "";
          fg = p.accent;
        }
        {
          "if" = "exec";
          text = "";
          fg = p.green;
        }
        {
          "if" = "!dir";
          text = "";
          fg = p.text;
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
