#!/bin/bash

DOTFILES=~/dotfiles   # path to your dotfiles repo
DATE=$(date +%s)

echo "==============================="
echo "Setting up dotfiles..."
echo "==============================="

# ------------------------
# Check/install Neovim
# ------------------------
if ! command -v nvim &> /dev/null; then
    echo "Neovim not found. Installing..."

    if [[ "$OSTYPE" == "darwin"* ]]; then
        brew install neovim

    elif [[ -f /etc/debian_version ]]; then
        if sudo -n true 2>/dev/null; then
            # sudo is available
            sudo apt update
            sudo apt install -y neovim curl
        else
            echo "No sudo. Installing Neovim locally..."
            mkdir -p ~/bin
            curl -Lo ~/bin/nvim.appimage https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
            chmod u+x ~/bin/nvim.appimage
            ln -sf ~/bin/nvim.appimage ~/bin/nvim
            export PATH="$HOME/bin:$PATH"
        fi

    else
        echo "Please install Neovim manually."
        exit 1
    fi
    echo "Neovim installed."
fi

# ------------------------
# Check/install tmux
# ------------------------
if ! command -v tmux &> /dev/null; then
    echo "tmux not found. Installing..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        brew install tmux
    elif [[ -f /etc/debian_version ]]; then
        if sudo -n true 2>/dev/null; then
            sudo apt install -y tmux
        else
            echo "No sudo: cannot install tmux system-wide. Please install manually."
        fi
    else
        echo "Please install tmux manually."
        exit 1
    fi
    echo "tmux installed."
fi

# ------------------------
# TMUX CONFIG
# ------------------------
if [ -f ~/.tmux.conf ]; then
    mv ~/.tmux.conf ~/.tmux.conf.backup.$DATE
    echo "Existing ~/.tmux.conf backed up."
fi
ln -sf $DOTFILES/tmux.conf ~/.tmux.conf
echo "tmux.conf symlinked."

if [ -d $DOTFILES/tmux ]; then
    if [ -d ~/.tmux ]; then
        mv ~/.tmux ~/.tmux.backup.$DATE
        echo "Existing ~/.tmux backed up."
    fi
    ln -sf $DOTFILES/tmux ~/.tmux
    echo "tmux folder symlinked."
fi

if [ ! -d ~/.tmux/plugins/tpm ]; then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    echo "TPM installed."
fi

tmux start-server \; run '~/.tmux/plugins/tpm/bin/install_plugins'
echo "tmux plugins installed."

# ------------------------
# NEOVIM CONFIG
# ------------------------
if [ -d ~/.config/nvim ]; then
    mv ~/.config/nvim ~/.config/nvim.backup.$DATE
    echo "Existing Neovim config backed up."
fi

mkdir -p ~/.config
ln -sf $DOTFILES/nvim ~/.config/nvim
echo "Neovim config symlinked."

# ------------------------
# lazy.nvim bootstrap
# ------------------------
LAZY_PATH="$HOME/.local/share/nvim/lazy/lazy.nvim"
if [ ! -d "$LAZY_PATH" ]; then
    git clone --filter=blob:none https://github.com/folke/lazy.nvim.git --branch=stable "$LAZY_PATH"
    echo "lazy.nvim installed."
fi

# ------------------------
# Install Neovim plugins (headless)
# ------------------------
nvim --headless -c 'lua require("lazy").sync()' -c 'qa'
echo "Neovim plugins installed."

echo "==============================="
echo "Dotfiles setup complete!"
echo "==============================="
