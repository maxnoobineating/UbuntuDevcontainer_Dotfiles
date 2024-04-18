#!/usr/bin/env bash
# vim/zsh/tmux package/plugins installation/setup

# core program installation
apt-get update && \
apt-get install -y \
        wget \
        git \
        curl \
        vim \
        tmux \
        zsh \
        sudo \
        man \
        locale \
        make

# Node installation
# installs NVM (Node Version Manager)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
# download and install Node.js
nvm install 21


# Oh-my-zsh Setup: https://ohmyz.sh/
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# oh-my-zsh plugin download
# powerlevel10k: https://github.com/romkatv/powerlevel10k?tab=readme-ov-file#installation
git clone https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k
# autosuggestions: https://github.com/romkatv/powerlevel10k?tab=readme-ov-file#installation
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
# syntax highlighting: https://github.com/zsh-users/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting


# Vim Setup
# Vim-plug Installation
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
# Ctags for easytags: https://vimawesome.com/plugin/easytags-vim
apt-get install -y exuberant-ctags


# Github CLI installation: https://github.com/cli/cli/blob/trunk/docs/install_linux.md
(type -p wget >/dev/null || (sudo apt update && sudo apt-get install wget -y)) \
&& sudo mkdir -p -m 755 /etc/apt/keyrings \
&& wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
&& sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
&& sudo apt update \
&& sudo apt install gh -y


# Tmux Setup
# for system without UTF-8 configured (else unicode char will be displayed as _)
sudo locale-gen "en_US.UTF-8"
# Tmux Plugin Manager Install
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm





