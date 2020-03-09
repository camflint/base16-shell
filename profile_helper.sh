#!/usr/bin/env bash
if [ -s "$BASH" ]; then
    file_name=${BASH_SOURCE[0]}
elif [ -s "$ZSH_NAME" ]; then
    file_name=${(%):-%x}
fi
script_dir=$(cd "$(dirname "$file_name")" && pwd)

. "$script_dir/realpath/realpath.sh"

# Specify BASE16_DUAL_TONE to select the light theme
theme_file_name=
if [ -v BASE16_DUAL_TONE ]; then
  theme_file_name="~/base16_theme_light"
else
  theme_file_name="~/base16_theme_dark"
fi

function load_theme_file() {
  local path=$1
  script_name=$(basename "$(realpath $path)" .sh)
  echo "export BASE16_THEME=${script_name#*-}"
  echo ". $them_file_name"
}
# If we've already got a generated theme file, load it.
if [ -f "$theme_file_name" ]; then
fi

cat <<'FUNC'
_base16()
{
  local script=$1
  local theme=$2
  [ -f $script ] && . $script
  ln -fs $script ~/.base16_theme
  export BASE16_THEME=${theme}
  echo -e "if \0041exists('g:colors_name') || g:colors_name != 'base16-$theme'\n  colorscheme base16-$theme\nendif" >| ~/.vimrc_background
  if [ -n ${BASE16_SHELL_HOOKS:+s} ] && [ -d "${BASE16_SHELL_HOOKS}" ]; then
    for hook in $BASE16_SHELL_HOOKS/*; do
      [ -f "$hook" ] && [ -x "$hook" ] && "$hook"
    done
  fi
}
FUNC
cat <<'FUNC'
_base16_dual_tone()
{
  local script=$1
  local theme=$2
  [ -f $script ] && . $script
  export BASE16_THEME=${theme}
  local target=
  [ -v BASE16_LIGHT ] && target=~/.base16_theme_light;
  [ -v BASE16_DARK ] && target=~/.base16_theme_dark;
  [ -z target ] && target=~/.base16_theme;
  echo -e "if '$BASE16_LIGHT' != ''\n  colorscheme base16-${theme}_light\nelseif '$BASE16_DARK' != ''\n  colorscheme base16-${theme}_dark\nendif" >| ~/.vimrc_background
  if [ -n ${BASE16_SHELL_HOOKS:+s} ] && [ -d "${BASE16_SHELL_HOOKS}" ]; then
    for hook in $BASE16_SHELL_HOOKS/*; do
      [ -f "$hook" ] && [ -x "$hook" ] && "$hook"
    done
  fi
}
FUNC

# Set up base16_* aliases.
for script in "$script_dir"/scripts/base16*.sh; do
  script_name=${script##*/}
  script_name=${script_name%.sh}
  theme=${script_name#*-}
  func_name="base16_${theme}"
  if [ -v BASE16_DUAL_TONE ]; then
    echo "alias $func_name=\"_base16_dual_tone \\\"$script\\\" $theme\""
  else
    echo "alias $func_name=\"_base16 \\\"$script\\\" $theme\""
  fi
done;
