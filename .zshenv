# ~/.zshenv


# export MANPAGER="vim -M +MANPAGER -"
export MANPAGER="sh -c 'col -bx | batcat --color=always -l man -p'"
# MANROFFOPT="-c" XXX not sure if
export MANROFFOPT="-c"

# for vim system() to call, zshrc is user zsh session loaded not loaded by zsh -c
man() {
  # for :Man in vim, because it seems to do man -w keyword instead of man keyword
  if [[ "$1" == "-w" ]]; then
    shift  # Remove '-w' from the arguments
    # echo "args? $@"
    command man "$@" 2> /dev/null 1> /dev/null
    if [[ $? -ne 0 ]]; then
      if [[ -z "$1" ]]; then
        echo "man: option requires an argument -- 'w'"
        return 1
      fi
      keyword="$@"
      # Create a temporary file
      temp_file=$(mktemp /tmp/"$(echo $keyword | tr ' ' '_')"_help.XXXXXX) || { echo "Failed to create temporary file"; return 1; }
      # echo "keyword is $keyword, temp_file is $temp_file"
      # Redirect the --help output to the temporary file
      if bash -r -c "eval \"$keyword --help\"" | eval $MANPAGER > "$temp_file" 2>&1; then
        echo "$temp_file"
      else
        echo "No manual entry for $keyword"
        rm -f "$temp_file"
        return 1
      fi
    else
      # command man " -w $@" 2>/dev/null
      command man -w "$@"
    fi
  else
    command man "$@" 2>/dev/null || "$@" --help 2>/dev/null | eval $MANPAGER
    # Attempt to display the manual page
    # command man "$@" 2>/dev/null 1>/dev/null

    # # If 'man' fails (exit status not zero), show --help output
    # if [ $? -ne 0 ]; then
    #   # echo "Manual page for '$1' not found. Displaying '$1 --help' with $MANPAGER instead:"
    #   "$@" --help 2>/dev/null | eval $MANPAGER
    #   return 0
    # else
    #   command man "$@"
    # fi
  fi
}