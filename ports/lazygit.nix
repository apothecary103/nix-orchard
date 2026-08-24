{ ... }:

let
  # catppuccin/lazygit, including the author colour, which is the one thing that
  # makes a busy log skimmable.
  theme = p: {
    gui.theme = {
      activeBorderColor = [
        p.accent
        "bold"
      ];
      inactiveBorderColor = [ p.subtext0 ];
      searchingActiveBorderColor = [ p.warning ];
      optionsTextColor = [ p.blue ];
      selectedLineBgColor = [ p.surface0 ];
      inactiveViewSelectedLineBgColor = [ p.overlay0 ];
      cherryPickedCommitFgColor = [ p.accent ];
      cherryPickedCommitBgColor = [ p.surface1 ];
      markedBaseCommitFgColor = [ p.blue ];
      markedBaseCommitBgColor = [ p.warning ];
      unstagedChangesColor = [ p.error ];
      defaultFgColor = [ p.text ];
    };

    gui.authorColors."*" = p.lavender;
  };
in
{
  # No hjem binding: lazygit takes one config.yml and there is no port to merge
  # a theme into, so writing the file would clobber the user's own.
  description = "lazygit";

  theme = { p, ... }: theme p;

  home = {
    when = { config, ... }: config.programs.lazygit.enable;
    config = { data, ... }: { programs.lazygit.settings = data; };
  };
}
