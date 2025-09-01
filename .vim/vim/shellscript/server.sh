#!/bin/zsh

# Infinite loop to read from the pipe
while true; do
    returnval="$(cat)"
    sleep 1
    echo "server - $returnval" | tee /dev/tty
    # if read line; then
    #     echo -n "server - " > /dev/tty
    #     # stdbuf -o0 -i0 echo "$line? gotit" | sleep 1 && cat | tee /dev/tty
    #     echo "$line? gotit"
    # else
    #     # If read fails, sleep briefly to prevent tight loop
    #     sleep 1
    # fi
done

