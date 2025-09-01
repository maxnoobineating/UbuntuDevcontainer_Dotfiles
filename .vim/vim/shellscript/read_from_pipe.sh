#!/bin/zsh
local p2relay_pipe="$1"
local relay2p_pipe="$2"

# Check if the pipe exists and is a named pipe
if [[ ! -p "$p2relay_pipe" ]]; then
  echo "$(date) - Error: $p2relay_pipe is not a named pipe." >> ./errorlog
    return 1
fi
if [[ ! -p "$relay2p_pipe" ]]; then
  echo "$(date) - Error: $relay2p_pipe is not a named pipe." >> ./errorlog
    return 1
fi

# Infinite loop to read from the pipe
# exec 4<"$p2relay_pipe"
# while read line <&4; do
# while read line <"$p2relay_pipe"; do
while true; do
  cat "$p2relay_pipe"
  cat > "$relay2p_pipe"
  # exec 3<>"$p2relay_pipe"
  # stdbuf -i0 -o0 cat "$p2relay_pipe" & # to vim
  # vim_stdin="$(cat < "$p2relay_pipe")"
  # echo "$vim_stdin"
  # cat <&3
  # exec 3<&-
  # echo "r 1" > /dev/tty
  # echo "$line" # to vim
  # sleep 1
  # vim_stdout="$(cat)"
  # sleep 1
  # exec 4<>"$relay2p_pipe"
  # cat >&4 # | tee /dev/tty >&3 # vim is expected to return something
  # stdbuf -o0 -i0 cat > "$relay2p_pipe"
  # echo "r 2" > /dev/tty
  # echo "$vim_stdout" > "$relay2p_pipe"
  # exec 4>&-
  # sleep 1
  # exec 4<"$p2relay_pipe"
  # echo "r 3" > /dev/tty
done

