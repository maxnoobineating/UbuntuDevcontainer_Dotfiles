alias sl=ls
alias dotfile="/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME"

PROMPT_COMMAND='history -a'

[[ -s "$HOME/.gvm/scripts/gvm" ]] && source "$HOME/.gvm/scripts/gvm"
. "/root/.deno/env"