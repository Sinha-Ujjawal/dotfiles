# --- Vi mode ---
bindkey -v
KEYTIMEOUT=1
setopt PROMPT_SUBST

MODE="[INSERT] "

function zle-keymap-select {
  case $KEYMAP in
    vicmd) MODE="[NORMAL] " ;;
    *)     MODE="[INSERT] " ;;
  esac
  zle reset-prompt
}

zle -N zle-keymap-select

function precmd {
  case $KEYMAP in
    vicmd) MODE="[NORMAL] " ;;
    *)     MODE="[INSERT] " ;;
  esac
}

# Disable all bells
setopt NO_BEEP
