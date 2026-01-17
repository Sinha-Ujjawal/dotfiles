#!/usr/bin/env bash

set -e

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

    read -r -p "Execute these commands? (y/n): " choice

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

ensure_source_line() {
    local rc_file="$1"
    local source_line="$2"

    usage() {
        echo "Usage ensure_source_line <rc_file> <source_line>"
    }

    if [[ -z "$rc_file" ]]; then
        usage
        echo "Error: <rc_file> not provided!"
        return 69
    fi
    if [[ -z "$source_line" ]]; then
        usage
        echo "Error: <source_line> not provided!"
        return 69
    fi

    echo "Append source line: \`$source_line\` to \`$rc_file\`"

    # Only proceed if the file exists
    if [[ ! -f "$rc_file" ]]; then
        echo "SKIPPED."
        return 0
    fi

    # Check if the line already exists (exact match)
    if ! grep -Fxq "$source_line" "$rc_file"; then
        read -r -p "Proceed? (y/n): " choice
        case "$choice" in
            [Yy]* )
                printf '\n%s\n' "$source_line" >> "$rc_file"
                ;;
            * )
                echo "SKIPPED."
                ;;
        esac
    else
        echo "SKIPPED."
    fi
}

append_if_missing() {
    local file="$1"
    local content="$2"

    usage() {
        echo "Usage append_if_missing <file> <content>"
    }

    if [[ -z "$file" ]]; then
        usage
        echo "<file> not provided!"
        return 69
    fi
    if [[ -z "$content" ]]; then
        usage
        echo "<content> not provided!"
        return 69
    fi

    # Check if the file exists; if not, create it or handle error
    if [[ ! -f "$file" ]]; then
        touch "$file"
    fi

    echo "Appending to $file"

    # Use grep to search for the exact content
    # -F: Interpret pattern as a fixed string (not a regex)
    # -x: Match the whole line(s)
    # -q: Quiet mode (don't output anything)
    # -z: Treat input as a set of lines terminated by null, allowing multi-line matching
    if ! grep -FqzZ "$content" "$file"; then
        read -r -p "Proceed? (y/n): " choice
        case "$choice" in
            [Yy]* )
                # Ensure the file ends with a newline before appending to avoid joining lines
                [[ -s "$file" && -n "$(tail -c1 "$file")" ]] && echo "" >> "$file"

                echo -e "$content" >> "$file"
                echo "Content appended to $file."
                ;;
             *)
                echo "SKIPPED."
                ;;
        esac
    else
        echo "SKIPPED."
    fi
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

# 6. GDB config directory
confirm_and_link "$DOTFILES_DIR/.config/gdb" "$HOME/.config/gdb" true
confirm_and_link "$DOTFILES_DIR/.config/gdb/gdbinit" "$HOME/.gdbinit" true

# 7. Appending to ~/.inputrc
if [[ ! -f "$HOME/.inputrc" ]]; then
    touch "$HOME/.inputrc"
fi
append_if_missing "$HOME/.inputrc"  "\$include $DOTFILES_DIR/.rc.files/.inputrc"

# 8. Appending to ~/.editrc
if [[ ! -f "$HOME/.editrc" ]]; then
    touch "$HOME/.editrc"
fi
append_if_missing "$HOME/.editrc"  "$(cat "$DOTFILES_DIR/.rc.files/.editrc")"

set -e
ensure_source_line "$HOME/.bashrc" "source $DOTFILES_DIR/.rc.files/.bashrc"
ensure_source_line "$HOME/.zshrc"  "source $DOTFILES_DIR/.rc.files/.zshrc"

echo ""
echo "Setup process finished."

set +e
