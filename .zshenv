# ~/.zshenv

# for vim system() to call, zshrc is user zsh session loaded not loaded by zsh -c
man() {
    # Attempt to display the manual page
    command man "$@" 2>/dev/null

    # If 'man' fails (exit status not zero), show --help output
    if [ $? -ne 0 ]; then
        # echo "Manual page for '$1' not found. Displaying '$1 --help' with $MANPAGER instead:"
        "$@" --help 2>/dev/null | eval $MANPAGER
    fi
}
