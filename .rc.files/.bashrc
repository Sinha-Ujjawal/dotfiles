# --- Enable vi mode ---
set -o vi

# --- Show vi mode in prompt ---
bind 'set keyseq-timeout 10'
bind 'set show-mode-in-prompt on'
bind 'set vi-ins-mode-string "[INSERT] "'
bind 'set vi-cmd-mode-string "[NORMAL] "'

# Ensure that Ctrl-l works in vi-mode
bind -m vi-insert  '\C-l: clear-screen'
bind -m vi-command '\C-l: clear-screen'

# --- Simple, identical prompt ---
PS1='\w\n$ '

# Disable terminal bell
bind 'set bell-style none'
