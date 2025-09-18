#!/bin/bash

DOTFILES=~/dotfiles
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
        # macOS
        if ! command -v brew &> /dev/null; then
            echo "Homebrew not found. Installing Homebrew first..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi
        brew install neovim

    elif [[ -f /etc/debian_version ]]; then
        # Debian/Ubuntu Linux
        sudo apt update
        sudo apt install -y neovim git curl

    else
        echo "Please install Neovim manually for your OS."
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
        sudo apt install -y tmux
    else
        echo "Please install tmux manually for your OS."
        exit 1
    fi

    echo "tmux installed."
fi

# ------------------------
# TMUX CONFIG
# ------------------------
# Backup existing tmux config
if [ -f ~/.tmux.conf ]; then
    mv ~/.tmux.conf ~/.tmux.conf.backup.$DATE
    echo "Existing ~/.tmux.conf backed up."
fi

ln -sf $DOTFILES/tmux.conf ~/.tmux.conf
echo "tmux.conf symlinked."

# Optional: symlink tmux folder if exists
if [ -d $DOTFILES/tmux ]; then
    if [ -d ~/.tmux ]; then
        mv ~/.tmux ~/.tmux.backup.$DATE
        echo "Existing ~/.tmux backed up."
    fi
    ln -sf $DOTFILES/tmux ~/.tmux
    echo "tmux folder symlinked."
fi

# Install TPM if missing
if [ ! -d ~/.tmux/plugins/tpm ]; then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    echo "TPM installed."
fi

# Install tmux plugins
tmux start-server \; run '~/.tmux/plugins/tpm/bin/install_plugins'
echo "tmux plugins installed."

# ------------------------
# NEOVIM CONFIG
# ------------------------
# Backup existing Neovim config
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
# Install Neovim plugins
# ------------------------
nvim --headless -c 'require("lazy").install() | qa'
echo "Neovim plugins installed."

echo "==============================="
echo "Dotfiles setup complete!"
echo "==============================="
