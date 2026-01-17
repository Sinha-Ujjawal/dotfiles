current_dir="$(cd "$(dirname "${BASH_SOURCE:-$0}")" && pwd)"
source "$current_dir/common.sh"

# --- Simple, identical prompt ---
PS1='\w$ '
