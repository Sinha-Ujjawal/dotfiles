# --- Enable vi mode ---
set -o vi

# --- Show vi mode in prompt ---
bind 'set show-mode-in-prompt on'
bind 'set vi-ins-mode-string "[INSERT] "'
bind 'set vi-cmd-mode-string "[NORMAL] "'

# --- Simple, identical prompt ---
PS1='\u@\h:\w $ '

# Disable terminal bell
set -o bell-style none
