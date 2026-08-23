# ashen/fish, verbatim. Commands are blaze-bold, the cwd orange rather than the
# accent, and the autosuggestion sits on brown — none of which falls out of a
# generic mapping.
{ p }:

let
  raw = p.raw;
  c = builtins.substring 1 6;
in
{
  fish_color_normal = c raw.g_3;
  fish_color_command = "${c raw.orange_blaze} -o";
  fish_color_param = c raw.g_2;
  fish_color_keyword = "${c raw.red_ember} -o";
  fish_color_quote = c raw.red_glowing;
  fish_color_redirection = c raw.orange_smolder;
  fish_color_end = c raw.orange_smolder;
  fish_color_comment = "${c raw.g_6} -i";
  fish_color_error = c raw.red_ember;
  fish_color_gray = c raw.g_6;
  fish_color_selection = "--background=${c raw.brown_dark}";
  fish_color_search_match = "${c raw.background} --background=${c raw.brown_dark}";
  fish_color_option = c raw.orange_glow;
  fish_color_operator = c raw.orange_blaze;
  fish_color_escape = c raw.g_2;
  fish_color_autosuggestion = c raw.brown;
  fish_color_cancel = c raw.red_ember;
  fish_color_cwd = c raw.blue;
  fish_color_user = c raw.red_ember;
  fish_color_host = c raw.orange_blaze;
  fish_color_host_remote = c raw.orange_blaze;
  fish_color_status = c raw.orange_glow;

  fish_pager_color_progress = c raw.orange_glow;
  fish_pager_color_prefix = c raw.orange_glow;
  fish_pager_color_completion = c raw.g_3;
  fish_pager_color_description = c raw.g_4;
}
