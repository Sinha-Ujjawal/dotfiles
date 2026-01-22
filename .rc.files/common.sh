#!/usr/bin/env bash

# My Aliases
alias gdb="gdb -q"
case "$(uname -s)" in
    Darwin)
        alias ldd='otool -L'
        ;;
esac

export VISUAL=vim
export EDITOR=vim

if [[ ":$PATH:" != *":$HOME/bin"* ]]; then
    export PATH="$HOME/bin:$PATH"
fi

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

# Reference: https://youtu.be/DsmKmmKbz_4?si=VWO1LbuSSWi55hNh
extract () {
  if [ -f "$1" ] ; then
    unrar2dir() {
      local folder_name="${1%.*}"
      mkdir -p "$folder_name" && unrar x "$1" "$folder_name/"
    }

    unzip2dir() {
      local folder_name="${1%.*}"
      unzip "$1" -d "$folder_name"
    }

    case $1 in
      *.tar.bz2)   tar xjvf   "$1" ;;
      *.tar.gz)    tar xzvf   "$1" ;;
      *.tar.xz)    tar xvf    "$1" ;;
      *.bz2)       bzip2 -d   "$1" ;;
      *.rar)       unrar2dir  "$1" ;;
      *.gz)        gunzip     "$1" ;;
      *.tar)       tar xf     "$1" ;;
      *.tbz2)      tar xjf    "$1" ;;
      *.tgz)       tar xzf    "$1" ;;
      *.zip)       unzip2dir  "$1" ;;
      *.Z)         uncompress "$1" ;;
      *.7z)        7z x       "$1" ;;
      *.ace)       unace x    "$1" ;;
      *)           echo "'$1' cannot be extracted via extract()"   ;;
    esac
  else
    echo "Usage: extract <file>"
  fi
}

compress() {
  if [ -n "$1" ] && [ -n "$2" ]; then
    case $1 in
      *.tar.bz2)   tar -cjvf "$1" "$2" ;;
      *.tar.gz)    tar -czvf "$1" "$2" ;;
      *.tar.xz)    tar -cvf  "$1" "$2" ;;
      *.tar)       tar -cvf  "$1" "$2" ;;
      *.bz2)       bzip2 -c  "$2" > "$1" ;;
      *.gz)        gzip -c   "$2" > "$1" ;;
      *.zip)       zip -r    "$1" "$2" ;;
      *.7z)        7z a      "$1" "$2" ;;
      *)           echo "'$1' cannot be compressed via compress()" ;;
    esac
  else
    echo "Usage: compress <output_file> <input_file_or_dir>"
  fi
}
