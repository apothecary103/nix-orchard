# ashen/fzf, verbatim. Note that it paints its own background rather than
# leaving it to the terminal, and that the pointer is the golden ember while
# everything else selecting sits on blaze.
{ p }:

let
  raw = p.raw;
in
{
  fg = raw.g_4;
  "fg+" = raw.g_2;
  bg = raw.background;
  "bg+" = raw.g_8;
  hl = raw.orange_blaze;
  "hl+" = raw.orange_smolder;
  info = raw.g_4;
  marker = raw.orange_blaze;
  prompt = raw.orange_blaze;
  spinner = raw.orange_glow;
  pointer = raw.orange_golden;
  header = raw.red_ember;
  border = raw.g_4;
  query = raw.g_2;
  gutter = raw.background;
}
