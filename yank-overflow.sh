#!/usr/bin/env sh
# Convenience wrapper to send ~/.yank_overflow (or a given file) in chunks.
#
# Usage:
#   yank-overflow             # chunks $YANK_OVERFLOW_FILE (default: ~/.yank_overflow)
#   yank-overflow /some/file  # chunks a specific file

exec "$HOME/bin/yank" --chunks "$@"
