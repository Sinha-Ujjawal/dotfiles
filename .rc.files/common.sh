#!/usr/bin/env bash

# My Aliases
alias gdb="gdb -q"
case "$(uname -s)" in
    Darwin)
        alias ldd='otool -L'
        ;;
esac

touchx() {
    local touch_args=()
    local files=()
    local dirs=()

    # Help message
    usage() {
        echo "Usage: touchx [TOUCH_FLAGS] <file1> [file2...]"
        echo "Creates files, ensures parent directories exist, and makes them executable."
        echo ""
        echo "Example:"
        echo "  touchx script.sh                # Create and chmod +x"
        echo "  touchx -t 202601011200 s1 s2    # Create with timestamp and chmod +x"
        echo "  touchx path/to/new/script.sh    # Auto-creates 'path/to/new/'"
        return 0
    }

    # 1. Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help) usage; return 0 ;;
            -*) touch_args+=("$1") ;;
            *)  files+=("$1")
                # Fast built-in path parsing (no subshell)
                local d="${1%/*}"
                [[ "$d" != "$1" ]] && dirs+=("$d")
                ;;
        esac
        shift
    done

    # 2. Check for files
    if [[ ${#files[@]} -eq 0 ]]; then
        usage
        return 1
    fi

    # 3. Batch Directory Creation (Only if needed)
    for d in "${dirs[@]}"; do
        [[ ! -d "$d" ]] && mkdir -p -- "$d"
    done

    # 4. High-Performance Batch Execution
    # One call to touch and one call to chmod for all files combined
    touch "${touch_args[@]}" -- "${files[@]}" && chmod +x -- "${files[@]}"
}

yank() {
    # Usage: yank [FILE...]
    # Wraps the OSC 52 copy logic into a reusable shell function.

    local input len max esc

    # Read input from files or stdin
    input=$(cat "$@")

    # Helper functions defined locally to avoid namespace pollution
    _yank_known() { command -v "$1" >/dev/null ;}
    _yank_maybe() { _yank_known "$1" && printf %s "$input" | "$@" ;}
    _yank_alive() { _yank_known "$1" && "$@" >/dev/null 2>&1 ;}

    # Length limits for OSC 52 (approx 74KB)
    len=$(printf %s "$input" | wc -c)
    max=74994

    if [ "$len" -gt "$max" ]; then
        printf "yank: input is %d bytes too long for OSC 52\n" "$((len - max))" >&2
    fi

    # 1. Copy via OSC 52 (Direct to Terminal/Mac)
    esc="\033]52;c;$(printf %s "$input" | head -c $max | base64 | tr -d '\r\n')\a"

    # Wrap for tmux passthrough if needed
    if [ -n "$TMUX" ] || [[ "$TERM" == screen* ]]; then
        esc="\033Ptmux;\033$esc\033\\"
    fi
    printf "$esc"

    # 2. Copy to tmux buffer (if inside tmux)
    if [ -n "$TMUX" ]; then
        _yank_maybe tmux load-buffer -
    fi

    # 3. Copy via X11 (if DISPLAY exists)
    if [ -n "$DISPLAY" ] && _yank_alive xhost; then
        _yank_maybe xsel -i -b || _yank_maybe xclip -sel c
    fi
}
