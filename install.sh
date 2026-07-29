#!/usr/bin/env bash
# Symlink this dotfiles checkout into place. Safe to re-run: existing correct
# links are left alone, anything else is backed up before being replaced.
#
# Usage:
#   ./install.sh            # link everything
#   ./install.sh --dry-run  # show what would happen, change nothing
set -euo pipefail

DOTFILES=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"
STAMP=$(date +%Y%m%d%H%M%S)
DRY_RUN=0
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=1

run() {
  if (( DRY_RUN )); then
    printf '    would run: %s\n' "$*"
  else
    "$@"
  fi
}

# link <source> <destination>   — source is repo-relative unless absolute
link() {
  local src="$1" dst="$2"
  [[ $src == /* ]] || src="$DOTFILES/$src"

  if [[ ! -e $src ]]; then
    printf '  !! missing, skipped: %s\n' "$src"
    return
  fi

  # Already pointing where we want it.
  if [[ -L $dst && $(readlink -- "$dst") == "$src" ]]; then
    printf '  ok  %s\n' "$dst"
    return
  fi

  # Something else is there (real file/dir, or a link elsewhere) — preserve it.
  if [[ -e $dst || -L $dst ]]; then
    printf '  bak %s -> %s.bak.%s\n' "$dst" "$dst" "$STAMP"
    run mv -- "$dst" "$dst.bak.$STAMP"
  fi

  printf '  ln  %s -> %s\n' "$dst" "$src"
  run mkdir -p -- "$(dirname -- "$dst")"
  run ln -s -- "$src" "$dst"
}

(( DRY_RUN )) && echo "DRY RUN — nothing will be changed"
echo "dotfiles: $DOTFILES"

echo "~/.config"
link fish    "$CONFIG/fish"
link ghostty "$CONFIG/ghostty"
link herdr   "$CONFIG/herdr"
link nvim    "$CONFIG/nvim"

# ~/.claude also holds credentials, session history and caches, so link the
# individual config files rather than the whole directory.
echo "~/.claude"
run mkdir -p -- "$HOME/.claude"
link claude/CLAUDE.md     "$HOME/.claude/CLAUDE.md"
link claude/settings.json "$HOME/.claude/settings.json"
link claude/hooks         "$HOME/.claude/hooks"

# Codex/other agents read AGENTS.md; point it at the same instructions.
# Via ~/.claude/CLAUDE.md (linked just above) to match the existing setup.
echo "~"
link "$HOME/.claude/CLAUDE.md" "$HOME/AGENTS.md"

echo "done"
