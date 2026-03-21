#!/usr/bin/env bash
set -euo pipefail

# uninstall.sh — Remove claude-context-window status bar from Claude Code settings.
# Usage: ./uninstall.sh

MARKER="claude-context-window"

CLAUDE_DIR="${HOME}/.claude"
STATUSLINE_DEST="${CLAUDE_DIR}/statusline.js"
SETTINGS_FILE="${CLAUDE_DIR}/settings.json"

GREEN='\033[32m'
DIM='\033[2m'
RESET='\033[0m'

ensure_deps() {
  if ! command -v jq >/dev/null 2>&1; then
    echo "Error: jq is required but not found in PATH" >&2
    exit 1
  fi
}

read_settings() {
  if [ -f "$SETTINGS_FILE" ]; then
    cat "$SETTINGS_FILE"
  else
    echo '{}'
  fi
}

ensure_deps

removed_script=false
removed_config=false

if [ -f "$STATUSLINE_DEST" ]; then
  rm -f "$STATUSLINE_DEST"
  removed_script=true
fi

if [ -f "$SETTINGS_FILE" ]; then
  settings="$(read_settings)"

  existing_cmd="$(echo "$settings" | jq -r '.statusLine.command // ""')"

  if echo "$existing_cmd" | grep -q "$MARKER"; then
    new_settings="$(echo "$settings" | jq 'del(.statusLine)')"
    echo "$new_settings" > "$SETTINGS_FILE"
    removed_config=true
  fi
fi

if [ "$removed_script" = false ] && [ "$removed_config" = false ]; then
  printf "${DIM}Nothing to uninstall.${RESET}\n"
  exit 0
fi

printf "\n${GREEN}✓ claude-context-window uninstalled${RESET}\n"
[ "$removed_script" = true ] && printf "  Removed: %s\n" "$STATUSLINE_DEST"
[ "$removed_config" = true ] && printf "  Cleaned: %s\n" "$SETTINGS_FILE"
printf "\n${DIM}Restart Claude Code to deactivate.${RESET}\n\n"
