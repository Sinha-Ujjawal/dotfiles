current_dir="$(cd "$(dirname "${BASH_SOURCE:-$0}")" && pwd)"
source "$current_dir/common.sh"

# --- Vi mode ---
bindkey -v
KEYTIMEOUT=1
setopt PROMPT_SUBST

MODE=""

function set-prompt-var {
  case $KEYMAP in
    vicmd) PROMPT='[NORMAL] %~$ ' ;;
    *)     PROMPT='%~$ ' ;;
  esac
}

function zle-keymap-select {
  set-prompt-var
  zle reset-prompt
}
zle -N zle-keymap-select

function precmd {
  set-prompt-var
}

# Ensure that Ctrl-l works in vi-mode
bindkey '^l' clear-screen

# Ensure that Ctrl-R (search reverse history) works in vi-mode
bindkey '^R' history-incremental-search-backward

PROMPT='%~$ '

# Disable all bells
setopt NO_BEEP
