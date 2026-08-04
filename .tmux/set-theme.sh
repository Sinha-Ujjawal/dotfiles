#!/usr/bin/env bash

THEME_DIR="$HOME/.tmux/themes"

theme="$1"

if [[ -z "$theme" ]]; then
    tmux display-menu \
        -T " Themes " \
        -x C -y C \
        "Zaibutsu"     z "run-shell '~/.tmux/set-theme.sh zaibutsu'" \
        "GruberDarker" g "run-shell '~/.tmux/set-theme.sh gruberdarker'" \
        "Retrobox"     r "run-shell '~/.tmux/set-theme.sh retrobox'"
    exit 0
fi

theme_file="$THEME_DIR/$theme.conf"

if [[ -f "$theme_file" ]]; then
    tmux source-file "$theme_file"
else
    tmux display-message "Unknown theme: $theme"
fi
