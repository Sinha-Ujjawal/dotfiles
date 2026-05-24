#!/usr/bin/env sh

# Reference: https://andrewbrookins.com/technology/copying-to-the-ios-clipboard-over-ssh-with-control-codes/
#
# Usage: yank [FILE...]
#        yank --chunks [FILE]
#
# Copies the contents of the given files (or stdin, if no files are given) to
# the terminal that runs this program.  If this program is run inside tmux(1),
# then it also copies the given contents into tmux's current clipboard buffer.
# If this program is run inside X11, then it also copies to the X11 clipboard.
#
# This is achieved by writing an OSC 52 escape sequence to the said terminal.
# The maximum length of an OSC 52 escape sequence is 100_000 bytes, of which
# 7 bytes are occupied by a "\033]52;c;" header, 1 byte by a "\a" footer, and
# 99_992 bytes by the base64-encoded result of 74_994 bytes of copyable text.
#
# If input exceeds 74_994 bytes, the content is saved to YANK_OVERFLOW_FILE
# and a notification message is yanked instead so you see it on paste.
#
# Use --chunks to send a large file in sequential OSC 52 chunks, prompting
# for 'y' between each chunk:
#
#   yank --chunks               # reads from YANK_OVERFLOW_FILE
#   yank --chunks /some/file    # reads from a specific file
#
# Called from tmux via:
#   bind-key -T copy-mode-vi y send-keys -X copy-pipe '$HOME/bin/yank > #{pane_tty}'
#
# NOTE: Enable passthrough in tmux.conf for OSC 52 to work:
#   set-window-option -g allow-passthrough on

# ── User config ────────────────────────────────────────────────────────────────
YANK_OVERFLOW_FILE="${YANK_OVERFLOW_FILE:-$HOME/.yank_overflow}"
# ───────────────────────────────────────────────────────────────────────────────

known() { command -v "$1" >/dev/null; }
alive() { known "$1" && "$@" >/dev/null 2>&1; }

printf_escape() {
  esc=$1
  test -n "$TMUX" -o -z "${TERM##screen*}" && esc="\033Ptmux;\033$esc\033\\"
  printf "$esc"
}

yank_chunk_b64() {
  # $1 = already base64-encoded chunk
  printf_escape "\033]52;c;$1\a"
}

# ── Chunked mode ───────────────────────────────────────────────────────────────
if [ "${1:-}" = "--chunks" ]; then
  shift
  chunkfile="${1:-$YANK_OVERFLOW_FILE}"

  if [ ! -f "$chunkfile" ]; then
    echo "yank: file not found: $chunkfile" >&2
    exit 1
  fi

  max=74994
  len=$(wc -c < "$chunkfile")
  total_chunks=$(( (len + max - 1) / max ))
  chunk=1
  offset=0

  echo "Sending $len bytes in $total_chunks chunk(s) from $chunkfile"

  while [ "$offset" -lt "$len" ]; do
    chunk_b64=$(dd if="$chunkfile" bs=1 skip="$offset" count="$max" 2>/dev/null | base64 | tr -d '\r\n')
    chunk_end=$(( offset + max < len ? offset + max : len ))

    yank_chunk_b64 "$chunk_b64"

    if [ "$chunk" -lt "$total_chunks" ]; then
      printf "Chunk %d/%d yanked (%d-%d of %d bytes). Paste it, then press 'y' for next chunk, any other key to abort: " \
        "$chunk" "$total_chunks" \
        "$((offset + 1))" "$chunk_end" "$len"

      old_stty=$(stty -g </dev/tty)
      stty -echo -icanon min 1 time 0 </dev/tty
      key=$(dd if=/dev/tty bs=1 count=1 2>/dev/null)
      stty "$old_stty" </dev/tty

      printf '\n'

      case "$key" in
        y|Y) : ;;
        *)
          printf 'Yank aborted at chunk %d/%d.\n' "$chunk" "$total_chunks"
          exit 0
          ;;
      esac
    else
      printf "Chunk %d/%d yanked (%d-%d of %d bytes).\n" \
        "$chunk" "$total_chunks" \
        "$((offset + 1))" "$chunk_end" "$len"
    fi

    offset=$(( offset + max ))
    chunk=$(( chunk + 1 ))
  done

  printf 'All %d chunks yanked from %s!\n' "$total_chunks" "$chunkfile"
  exit 0
fi

# ── Normal mode ────────────────────────────────────────────────────────────────

# Store input in a temp file to safely handle all byte values (including nulls)
tmpfile=$(mktemp)
trap 'rm -f "$tmpfile"' EXIT
cat "$@" > "$tmpfile"
input() { cat "$tmpfile"; }

maybe() { known "$1" && input | "$@"; }

max=74994
len=$(input | wc -c)

copy_side_channels() {
  test -n "$TMUX" && maybe tmux load-buffer -
  test -n "$DISPLAY" && alive xhost && {
    maybe xsel -i -b || maybe xclip -sel c
  }
  test -f /c/Windows/System32/clip && {
    maybe /c/windows/System32/clip
  }
}

if [ "$len" -le "$max" ]; then
  # Fast path: fits within OSC 52 limit, yank normally
  printf_escape "\033]52;c;$(input | base64 | tr -d '\r\n')\a"
  copy_side_channels
else
  # Overflow: save content to file, yank a notification message instead
  input > "$YANK_OVERFLOW_FILE"
  msg="[Yank overflow: content too large ($len bytes). Saved to $YANK_OVERFLOW_FILE — run: yank --chunks]"
  printf_escape "\033]52;c;$(printf '%s' "$msg" | base64 | tr -d '\r\n')\a"
  # Overwrite tmux's buffer with the notification message too
  test -n "$TMUX" && printf '%s' "$msg" | tmux load-buffer -
  # Overwrite X11 clipboard too if available
  test -n "$DISPLAY" && alive xhost && {
    printf '%s' "$msg" | xsel -i -b 2>/dev/null || \
    printf '%s' "$msg" | xclip -sel c 2>/dev/null
  }
fi

exit 0
