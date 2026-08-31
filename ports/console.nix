{ lib, render }:

{
  description = "the Linux virtual console";

  # This is system-wide rather than scoped to an already-enabled application.
  activation = "explicit";

  theme = { p, ... }: map render.noHash p.terminal.ansi;

  nixos = { data, ... }: { console.colors = lib.mkDefault data; };
}
