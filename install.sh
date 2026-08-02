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

# Ghostty has no OS conditionals, so config.ghostty includes ?config.os and we
# point that at the right file for this machine.
echo "per-OS config"
case "$(uname -s)" in
  Darwin) link ghostty/config.macos "$DOTFILES/ghostty/config.os" ;;
  Linux)  link ghostty/config.linux "$DOTFILES/ghostty/config.os" ;;
  *)      printf '  !! unknown OS %s, skipping ghostty/config.os\n' "$(uname -s)" ;;
esac

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

# Reusable agent personas — one source of truth in agents/, linked into every
# tool that reads a name+description markdown: Claude Code subagents and
# Antigravity/Gemini skills. No model is pinned; whichever CLI runs the file
# decides the model, which is what keeps the personas tool-agnostic.
echo "agent personas"
for persona in "$DOTFILES"/agents/*.md; do
  name=$(basename -- "$persona" .md)
  link "$persona" "$HOME/.claude/agents/$name.md"
  link "$persona" "$HOME/.gemini/config/skills/$name/SKILL.md"
done

# Codex/other agents read AGENTS.md; point it at the same instructions.
# Via ~/.claude/CLAUDE.md (linked just above) to match the existing setup.
echo "~"
link "$HOME/.claude/CLAUDE.md" "$HOME/AGENTS.md"

echo "done"
