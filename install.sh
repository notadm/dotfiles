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

# ------------------------
# Zsh setup with Dave Verwer theme
# ------------------------
ZSHRC=~/.zshrc

# Backup existing .zshrc
if [ -f "$ZSHRC" ]; then
    mv "$ZSHRC" "$ZSHRC.backup.$DATE"
fi

# Install Oh My Zsh if missing
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}

# Plugins
[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ] && \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ] && \
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"

# Write .zshrc
cat > "$ZSHRC" << 'EOF'
export PATH="$HOME/bin:$HOME/.local/bin:$PATH"
alias ll='ls -la'
alias gs='git status'
alias gco='git checkout'
alias gl='git log --oneline --graph --decorate'
alias nv='nvim'
alias ..='cd ..'
alias ...='cd ../..'

export EDITOR='nvim'
export VISUAL='nvim'

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="daveverwer"
plugins=(git zsh-syntax-highlighting zsh-autosuggestions)
source $ZSH/oh-my-zsh.sh

export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced
alias ls='ls -GFh'
EOF

echo "Zsh setup complete with Dave Verwer theme!"
echo "==============================="
echo "Dotfiles setup complete!"
echo "==============================="
echo "Please restart your terminal or run 'source ~/.zshrc' to activate Zsh."
