{ render, ... }:

{
  description = "the Linux virtual console";

  theme = { p, ... }: map render.noHash p.ansi;

  nixos = { data, ... }: { console.colors = data; };
}
