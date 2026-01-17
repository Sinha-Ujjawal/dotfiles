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
