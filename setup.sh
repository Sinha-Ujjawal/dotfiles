#!/usr/bin/env bash

# 1. Automatically find the dotfiles directory relative to this script
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "===================================================="
echo " DOTFILES SETUP 2026"
echo " Detected source: $DOTFILES_DIR"
echo "===================================================="

# Function to display commands and ask for confirmation
confirm_and_link() {
    local source="$1"
    local target="$2"
    local is_dir="$3"

    # Check if the target is already a symlink pointing to the correct source
    if [[ -L "$target" ]]; then
        local current_link
        current_link=$(readlink "$target")
        if [[ "$current_link" == "$source" ]]; then
            echo "SKIPPED: $target is already correctly linked to $source."
            return 0
        fi
    fi

    echo ""
    echo "Task: Link $target"
    echo "Commands to be executed:"

    if [ "$is_dir" = true ]; then
        echo "  rm -rf $target"
        echo "  mkdir -p $(dirname "$target")"
        echo "  ln -s $source $target"
    else
        echo "  rm $target"
        echo "  mkdir -p $(dirname "$target")"
        echo "  ln -s $source $target"
    fi

    read -p "Execute these commands? (y/n): " choice

    case "$choice" in
        [Yy]* )
            if [ "$is_dir" = true ]; then rm -rf "$target"; else rm -f "$target"; fi
            mkdir -p "$(dirname "$target")"
            ln -s "$source" "$target"
            echo "DONE."
            ;;
        * )
            echo "SKIPPED."
            ;;
    esac
}

# --- Execution Steps ---

# 1. .vimrc
confirm_and_link "$DOTFILES_DIR/.vimrc" "$HOME/.vimrc" false

# 2. .vim directory
confirm_and_link "$DOTFILES_DIR/.vim" "$HOME/.vim" true

# 3. Neovim config directory
confirm_and_link "$DOTFILES_DIR/.config/nvim" "$HOME/.config/nvim" true

# 4. .tmux.conf
confirm_and_link "$DOTFILES_DIR/.tmux.conf" "$HOME/.tmux.conf" false

# 5. .aider.conf.yml
confirm_and_link "$DOTFILES_DIR/.aider.conf.yml" "$HOME/.aider.conf.yml" false

echo ""
echo "Setup process finished."
