#!/bin/bash

set -e

DOTFILES=~/dotfiles   # path to your dotfiles repo
DATE=$(date +%s)

echo "==============================="
echo "Setting up dotfiles..."
echo "==============================="

# ------------------------
# Check/install Neovim >=0.8
# ------------------------
NEOVIM_OK=0
if command -v nvim &> /dev/null; then
    NV_VER=$(nvim --version | head -n1 | awk '{print $2}' | tr -d v)
    NV_MAJOR=$(echo $NV_VER | cut -d. -f1)
    NV_MINOR=$(echo $NV_VER | cut -d. -f2)
    if [ "$NV_MAJOR" -gt 0 ] || ([ "$NV_MAJOR" -eq 0 ] && [ "$NV_MINOR" -ge 8 ]); then
        NEOVIM_OK=1
    fi
fi

if [ "$NEOVIM_OK" -eq 0 ]; then
    echo "Neovim not found or too old. Installing latest locally..."
    mkdir -p ~/bin
    cd ~/bin
    curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
    chmod u+x nvim.appimage
    mv nvim.appimage nvim
    export PATH="$HOME/bin:$PATH"
fi

echo "Neovim ready: $(nvim --version | head -n1)"

# ------------------------
# Remove packer if exists (use lazy.nvim only)
# ------------------------
rm -rf ~/.local/share/nvim/site/pack/packer
rm -f ~/.config/nvim/plugin/packer_compiled.lua
echo "Removed Packer.nvim to use lazy.nvim only."

# ------------------------
# Check/install tmux
# ------------------------
if ! command -v tmux &> /dev/null; then
    echo "tmux not found. Installing..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        brew install tmux
    elif [[ -f /etc/debian_version ]]; then
        if sudo -n true 2>/dev/null; then
            sudo apt update
            sudo apt install -y tmux git curl
        else
            echo "No sudo: cannot install tmux system-wide. Please install manually."
        fi
    else
        echo "Please install tmux manually."
        exit 1
    fi
fi

# ------------------------
# TMUX CONFIG
# ------------------------
if [ -f ~/.tmux.conf ]; then
    mv ~/.tmux.conf ~/.tmux.conf.backup.$DATE
fi
ln -sf $DOTFILES/tmux.conf ~/.tmux.conf

if [ -d $DOTFILES/tmux ]; then
    if [ -d ~/.tmux ]; then
        mv ~/.tmux ~/.tmux.backup.$DATE
    fi
    ln -sf $DOTFILES/tmux ~/.tmux
fi

if [ ! -d ~/.tmux/plugins/tpm ]; then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

tmux start-server \; run '~/.tmux/plugins/tpm/bin/install_plugins'

# ------------------------
# NEOVIM CONFIG
# ------------------------
if [ -d ~/.config/nvim ]; then
    mv ~/.config/nvim ~/.config/nvim.backup.$DATE
fi
mkdir -p ~/.config
ln -sf $DOTFILES/nvim ~/.config/nvim

# ------------------------
# lazy.nvim bootstrap
# ------------------------
LAZY_PATH="$HOME/.local/share/nvim/lazy/lazy.nvim"
if [ ! -d "$LAZY_PATH" ]; then
    git clone --filter=blob:none https://github.com/folke/lazy.nvim.git --branch=stable "$LAZY_PATH"
fi

# ------------------------
# Install Neovim plugins (headless)
# ------------------------
nvim --headless -c 'lua require("lazy").sync()' -c 'qa'

echo "==============================="
echo "Dotfiles setup complete!"
echo "==============================="
