#!/bin/sh
# Claude Code status line — single line, fits terminal width
# Layout: user@host  <path><git>  model<ctx><vim>  time

input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')
model=$(echo "$input" | jq -r '.model.display_name // ""')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
vim_mode=$(echo "$input" | jq -r '.vim.mode // empty')

# Terminal width (tmux-aware via $COLUMNS or tput)
cols="${COLUMNS:-$(tput cols 2>/dev/null || echo 80)}"

# Shorten home to ~
short_cwd=$(echo "$cwd" | sed "s|^$HOME|~|")

# Git branch
git_branch=""
if git -C "$cwd" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git_branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null \
    || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
fi

# Colors
cyan='\033[0;36m'
green='\033[0;32m'
yellow='\033[0;33m'
blue='\033[0;34m'
magenta='\033[0;35m'
red='\033[0;31m'
reset='\033[0m'

user_host="$(whoami)@$(hostname -s)"
time_str=$(date +%H:%M:%S)

# Build plain-text versions of fixed segments (for width calculation)
git_plain=""
git_col=""
if [ -n "$git_branch" ]; then
  git_plain="  $git_branch"
  git_col="  $(printf "${green}%s${reset}" "$git_branch")"
fi

ctx_plain=""
ctx_col=""
if [ -n "$used_pct" ]; then
  used_int=$(printf "%.0f" "$used_pct")
  ctx_plain=" ctx:${used_int}%"
  if   [ "$used_int" -ge 80 ]; then ctx_color="$red"
  elif [ "$used_int" -ge 50 ]; then ctx_color="$yellow"
  else                               ctx_color="$green"
  fi
  ctx_col=" $(printf "${ctx_color}ctx:${used_int}%%${reset}")"
fi

vim_plain=""
vim_col=""
if [ -n "$vim_mode" ]; then
  vim_plain=" [$vim_mode]"
  vim_col=" $(printf "${magenta}[%s]${reset}" "$vim_mode")"
fi

# Total fixed width (everything except the path itself)
# Layout chars: "  " after user_host, "  " after path+git, "  " before time
fixed="${user_host}  ${git_plain}  ${model}${ctx_plain}${vim_plain}  ${time_str}"
fixed_len=${#fixed}
avail=$((cols - fixed_len))

# Truncate path to fit, keeping tail (e.g. ...oo/bar/baz)
path_len=${#short_cwd}
if [ "$avail" -le 3 ]; then
  short_cwd="..."
elif [ "$path_len" -gt "$avail" ]; then
  keep=$((avail - 3))
  short_cwd="...$(printf '%s' "$short_cwd" | tail -c "$keep")"
fi

printf "${cyan}%s${reset}  ${blue}%s${reset}%s  ${yellow}%s${reset}%s%s  ${reset}%s\n" \
  "$user_host" \
  "$short_cwd" \
  "$git_col" \
  "$model" \
  "$ctx_col" \
  "$vim_col" \
  "$time_str"
