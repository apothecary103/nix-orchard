{ lib, ... }:

let
  # catppuccin/lazygit.
  theme = p: {
    gui.theme = {
      activeBorderColor = [
        p.ui.accent
        "bold"
      ];
      inactiveBorderColor = [ p.surface.textDim ];
      searchingActiveBorderColor = [ p.status.warning ];
      optionsTextColor = [ p.hue.blue ];
      selectedLineBgColor = [ p.surface.neutral0 ];
      inactiveViewSelectedLineBgColor = [ p.surface.neutral3 ];
      cherryPickedCommitFgColor = [ p.ui.accent ];
      cherryPickedCommitBgColor = [ p.surface.neutral1 ];
      markedBaseCommitFgColor = [ p.hue.blue ];
      markedBaseCommitBgColor = [ p.status.warning ];
      unstagedChangesColor = [ p.status.error ];
      defaultFgColor = [ p.surface.text ];
    };

    gui.authorColors."*" = p.ui.secondaryAccent;
  };
in
{
  # No hjem binding: lazygit takes one config.yml, so a file would clobber it.
  description = "lazygit";

  theme = { p, ... }: theme p;

  home = {
    when = { config, ... }: config.programs.lazygit.enable;
    config =
      { data, ... }:
      {
        programs.lazygit.settings = lib.mapAttrsRecursive (_: lib.mkDefault) data;
      };
  };
}
