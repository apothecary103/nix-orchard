{ render, ... }:

{
  description = "the Linux virtual console";

  theme = { p, ... }: map render.noHash p.terminal.ansi;

  nixos = { data, ... }: { console.colors = data; };
}
