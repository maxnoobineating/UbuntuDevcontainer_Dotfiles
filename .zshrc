# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi


# go path
export GOPATH=$HOME/go
export GOBIN=$GOPATH/bin
export PATH=$PATH:$GOBIN

# set time zone
# TZ='Asia/Taipei'; export TZ
TZ='America/Los_Angeles'; export TZ

# C environment setup
export VERITY_LIBRARY_PATH="$HOME/nand2tetris_volumn/myLib"
# include path as if compiled with -I<dir> option
export CPATH="$CPATH:$VERITY_LIBRARY_PATH/C/include/"
# library path as if compiled with -L<dir> option (statically linked)
export LIBRARY_PATH="$LIBRARY_PATH:$VERITY_LIBRARY_PATH/C/lib/"
# library path for dynamically linked libary - because dynamic .so linking *happens in runtime*
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$VERITY_LIBRARY_PATH/C/lib/"

# automatically move mylib.c and mylib.h to $VERITY_LIBRARY_PATH
function export_Clib() {
  echo $PWD
  mv $1.c $VERITY_LIBRARY_PATH/C/lib/
  mv $1.h $VERITY_LIBRARY_PATH/C/include/
  ln -s $VERITY_LIBRARY_PATH/C/lib/$1.c $1.c
  ln -s $VERITY_LIBRARY_PATH/C/include/$1.h $1.h
}


# built-in completion enable
autoload -Uz compinit
compinit

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes

ZSH_THEME="powerlevel10k/powerlevel10k"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git zsh-autosuggestions zsh-syntax-highlighting z) # zsh-vi-mode)

####
# zsh-vi-mode config
# ZVM_CONFIG_FUNC = zvm_config by default
# function zvm_config() {
#   # ZVM_LINE_INIT_MODE=$ZVM_MODE_INSERT
#   bindkey -M normal '-' '$'
# }


source $ZSH/oh-my-zsh.sh

# User configuration

# color correction
export TERM="xterm-256color"
# export TERM="tmux-256color"

# export MANPATH="/usr/local/man:$MANPATH"
export PYTHONPATH="/root/.ipython/extensions"
export IPYTHONDIR="/root/.ipython"

# You may need to manually set your language environment
export LC_ALL="en_US.UTF-8"
export LANG="en_US.UTF-8"

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh


ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE=fg=yellow

ZSH_HIGHLIGHT_STYLES[comment]=fg=magenta
ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]=fg=magenta
ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]=fg=magenta
ZSH_HIGHLIGHT_STYLES[back-dollar-quoted-argument]=fg=magenta
alias dotfile='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'

# pre-prompt executed commands:
# precmd () {
#
# }


# setting that update the history file before the command is executed.
setopt inc_append_history
setopt share_history

# copy command history into sys clipboard aliases
function hcp () {
				num_line=1
				while getopts 'n:' flag; do
								case "${flag}" in
												n) num_line="${OPTARG}" ;;
												*) echo "Unexpected option ${flag}" 1>&2 ;;
								esac
				done
				cat ~/.zsh_history | tail --lines=$((num_line + 1)) | head --lines=1 | cut -d';' -f2- | xclip -sel clip
}

# history file corruption fix
function history_corruption_fix () {
	cd ~
	mv .zsh_history .zsh_history_bad
	strings .zsh_history_bad > .zsh_history
	fc -R .zsh_history
	rm .zsh_history_bad
}

# vim profile.log top 10 time consumer report
function listVimProfile() {
    local file='/tmp/vim_profile.log'

    # Extract lines with 'Total time:' and the number, sort them in descending order
    grep 'Total time:' $file | awk '{print $3}' | sort -nr | head -10 | sort -n | while read line
    do
        # For each number, find the corresponding 'Total time:' line, and print 3 lines before and 1 line after
        grep -B 3 -A 1 "Total time:   $line" $file
        echo
    done
}
# vim startup top 20 time consumer
# function listVimStartupProfile() {
#     # Validate arguments
#     if [[ $# -ne 1 ]]; then
#         echo "Usage: listVimStartupProfile <script_file>"
#         return 1
#     fi

#     local script_file="$1"

#     # Check if script file exists
#     if [[ ! -f "$script_file" ]]; then
#         echo "Error: Script file '$script_file' does not exist."
#         return 1
#     fi

#     # Define temporary profile file
#     local profile_file="/tmp/vim_startup_profile.log"

#     # Generate Vim startup profile
#     vim --startuptime "$profile_file" "$script_file"

#     # Define regular expressions for parsing
#     local re_timestamp='^([0-9.]+)\s+([0-9.]+):'  # Matches timestamp
#     local re_sourced_script='^(.*?):\s+(.*)$'   # Matches sourced script details
#     local dtimefile='/tmp/profile_sorted.tmp'

#     # Calculate delta time for each line (previous - current)
#     awk -v RS='\n' 'NR > 1 { delta = $1 - prev; prev = $1; print delta, $0 } { prev = $1 }' "$profile_file" | sort -nrk1 | head -20 > $dtimefile

#     # Process each entry in the sorted list
#     while IFS= read -r delta line; do
#     # Check if line starts with a timestamp (valid entry)
#     if [[ $line =~ ^$re_timestamp ]]; then
#       # Extract timestamp and elapsed time (if available)
#       elapsed=${BASH_REMATCH[2]}  # Second capture group (elapsed)
#       timestamp=${BASH_REMATCH[1]}

#       # Print information based on elapsed time availability
#       if [[ -n "$elapsed" ]]; then
#         local total_time_line=$(grep -m 1 "^Total time:    $elapsed" "$profile_file")
#         # Check if line was found
#         if [[ -n "$total_time_line" ]]; then
#           # Extract script name (if sourced)
#           local script_name=$(grep -Eo "$re_sourced_script" <<<"$total_time_line")
#           script_name=${script_name##*:}  # Remove timestamp

#           # Print output with script name (if available)
#           echo "Delta time: $delta ms (from ${timestamp}ms)"
#           if [[ -n "$script_name" ]]; then
#             echo "Sourced script: $script_name"
#           fi
#           echo "$line"
#           echo
#         fi
#       else
#         # Print for lines without elapsed time but with valid timestamp
#         echo "Delta time: $delta ms (no elapsed time available)"
#         echo "$line"
#         echo
#       fi
#     fi
#     done < $dtimefile
#     rm $dtimefile
# }




# copilot shortcut
alias cosugg='gh copilot suggest'
alias coexpl='gh copilot explain'


# set ipdb to be the default breakpoint debugger
export PYTHONBREAKPOINT="IPython.terminal.debugger.set_trace"

# adding go into PATH
export PATH=$PATH:/usr/local/go/bin
# adding python package into PATH
export PATH="$HOME/.local/bin:$PATH"

# adding ctags into PATH
export PATH=$PATH:$HOME/ctags


# highlight views of cat
hcat() {
	case "$1" in
		*.md)
			mdless "$1";;
		*)
			highlight -O ansi --force "$1";;
	esac
}

gitdl() {
  # Usage: gitdl <github_url>
  # Example: gitdl https://github.com/cirosantilli/test-git-partial-clone-big-small-no-bigtree/small
  #
  # The script:
  #   1. Parses the GitHub URL into the repository URL and the target directory (if provided).
  #   2. Clones the repo partially with --depth=1, --filter=tree:0.
  #   3. Enables sparse-checkout to fetch only the target directory.
  #   4. Moves the target directory’s contents (only) to the current working directory.
  #   5. Deletes the temporary clone.
  # set -e
  if [ "$#" -lt 2 ]; then
      echo "Usage: $0 <github_url>"
      exit 1
  fi
  # Save the original directory (destination)
  orig_dir=$(pwd)
  # Get the provided URL and remove any trailing slash or query string.
  github_url="$1"
  github_url="${github_url%/}"
  github_url="${github_url%%\?*}"
  # cuz github don't always structure url to reflect dir path (e.g. <repo_url>/tree/main/<actual-path>)
  # just specify it yourself, github give you a copy-path button for that
  target_path="$2"
  # We expect URLs starting with "https://github.com/"
  prefix="https://github.com/"
  if [[ "$github_url" != "$prefix"* ]]; then
      echo "Error: URL must start with $prefix"
      exit 1
  fi
  # Remove the prefix to extract the remainder: user/repo[/subdir...]
  rest="${github_url#$prefix}"
  user=$(echo "$rest" | cut -d'/' -f1)
  repo=$(echo "$rest" | cut -d'/' -f2)
  repo_url="$prefix$user/$repo.git"
  # If extra path components exist, that’s our target directory.
  # target_path=$(echo "$rest" | cut -d'/' -f3-)
  if [ -n "$target_path" ]; then
      # Prepend a slash to match sparse-checkout syntax.
      target_path="/$(echo "$target_path" | sed 's|^/||')"
      echo "Target directory specified: $target_path"
  else
      echo "No target directory specified; entire repository (without .git) will be downloaded."
  fi
  # Create a temporary directory for cloning.
  tmpdir=$(mktemp -d)
  echo "Cloning repository into temporary directory: $tmpdir"
  cd "$tmpdir"
  git clone -n --depth=1 --filter=tree:0 "$repo_url"
  cd "$repo"
  # If a target directory was specified, use sparse-checkout.
  if [ -n "$target_path" ]; then
      echo "Setting sparse checkout for target: $target_path"
      git sparse-checkout init --cone
      # ls -rla ./
      git sparse-checkout set --no-cone "$target_path"
  fi
  git checkout
  # Now, move the target files to the original directory.
  if [ -n "$target_path" ]; then
      # Remove the leading slash to get the folder name relative to repo root.
      target_folder=$(echo "$target_path" | sed 's|^/||')
      echo "Moving files from '$target_folder' to '$orig_dir'"
      mv ./"$target_folder"/* "$orig_dir"/
  else
      echo "Moving repository files (excluding .git) to '$orig_dir'"
      mv --exclude='.git' ./* "$orig_dir"/
  fi
  # Clean up the temporary directory.
  cd "$orig_dir"
  rm -rf "$tmpdir"
  echo "Done."
}

# alias hist10="history | awk '{$1="";print substr($0,2)}' | sort | uniq -c | sort -n | tail -n 10"
alias hist10="history 1 | awk '{\$1=\"\";print substr(\$0,2)}' | sort | uniq -c | sort -n | tail -n 10"
alias sl=ls
alias dc=cd
alias py=ipython
alias python='python3'
alias info='info --vi-keys'
alias wtf='tldr'
alias asmcat='objdump -M intel -d --no-show-raw-insn -C -j .text'

# command in-line substitution disable?
# DISABLE_MAGIC_FUNCTIONS=true
# source $ZSH/oh-my-zsh.sh


# [[ -s "$HOME/.gvm/scripts/gvm" ]] && source "$HOME/.gvm/scripts/gvm"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

alias nvim="~/nvim-linux64/bin/nvim"

OSSUDIR="$HOME/Desktop/Core system/nand2tetris_1"; alias b2w='cd $OSSUDIR'


