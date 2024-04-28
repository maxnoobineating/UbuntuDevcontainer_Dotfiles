# Managing Dotfiles with a Bare Git Repository
For first setting up, run:
`/bin/zsh <(curl -sSL https://gist.github.com/maxnoobineating/e42e875d0360dec9122ab5d088e66fd0.txt)`
Somehow bash wouldn't let me run the script
if automatic plugin installation isn't working in setup, try:
- vim:      :PlugInstall
- tmux:     <prefix> + I


https://stackoverflow.com/questions/75276760/git-fetch-remote-name-does-nothing-but-git-fetch-remote-url-fetches-the-cha
Problem with local repo not having proper remote tracking branch:
- Add `fetch = refs/heads/*:refs/remotes/origin/*` to ~/.cfg/config [branch "origin"]
- `dotfile pull` resolving conflict if there's version mismatch

## Introduction
This technique allows you to store your dotfiles in a bare Git repository located in a "side" folder (like `$HOME/.cfg` or `$HOME/.myconfig`). A specially crafted alias is used to run commands against this repository instead of the usual `.git` local folder¹.

## Prerequisites
- Git should be installed¹.

## Manual Setup
1. **Create a bare Git repository** in a side folder: `git init --bare $HOME/.cfg`¹.
2. **Create an alias** to interact with the configuration repository: `alias dotfile='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'`¹.
3. **Set a flag** to hide files not explicitly tracked yet: `dotfile config --local status.showUntrackedFiles no`¹.
4. **Add the alias definition** to your .bashrc: `echo "alias dotfile='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'" >> $HOME/.bashrc`¹.

## Usage
After setup, any file within the `$HOME` folder can be versioned with normal commands, replacing `git` with the `dotfile` alias¹. For example:
- `dotfile status`
- For adding new untracked file `dotfile add .vimrc`
- For updating tracked files `dotfile add -u`
- For staging+committing tracked files updates `dotfile commit -a`
- `dotfile push`
- removing unwanted files (cache, logs):
  `dotfile ls-files | egrep '(cache|log)' | xargs -I {} bash -c '/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME rm -r --cached {}' &&`
  `dotfile ls-files | grep -Po '\..*(cache|log).*?(?=/)' | uniq >> .gitignore`

## Migrating to This Setup
If you already store your configuration/dotfiles in a Git repository, you can migrate to this setup with the following steps¹:
1. **Commit the alias** to your .bashrc or .zsh: `alias dotflile='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'`¹.
2. **Ignore the folder** where you'll clone it in your source repository¹.

## Other Manual Changes
Oh-My-Zsh setup: https://www.kwchang0831.dev/dev-env/ubuntu/oh-my-zsh#an1-zhuang1-bi4-yao4-de-tao4-jian4

## References
- [Atlassian Tutorial](^1^)

Source: Conversation with Bing, 10/3/2023
(1) How to Store Dotfiles - A Bare Git Repository - Atlassian. https://www.atlassian.com/git/tutorials/dotfiles.
(2) How to Store Dotfiles - A Bare Git Repository - Atlassian. https://www.atlassian.com/git/tutorials/dotfiles.
(3) How to handle big repositories with Git | Atlassian Git Tutorial. https://www.atlassian.com/git/tutorials/big-repositories.
(4) .gitignore file - ignoring files in Git | Atlassian Git Tutorial. https://www.atlassian.com/git/tutorials/saving-changes/gitignore.
(5) undefined. http://bit.do/cfg-init.
