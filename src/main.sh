#!/usr/bin/env bash
set -e
VERSION=0.0.1-alpha
CONFIG_FILE="${ARCHITECT_CONFIG:-/etc/architect.sh}"
check_config() {
  [[ -f "$CONFIG_FILE" ]] && source $CONFIG_FILE && return
  [[ " $* " == *" --make-config "* ]] && return
  echo "[!] Config file not found: $CONFIG_FILE" >&2
  exit 1
}
check_config "$@"
DRY_RUN=0
FORCE=0
ARCHITECT_DIR="${ARCHITECT_DIR:-$HOME/.architect}"
[[ " $* " == *" --dry-run "* ]] && DRY_RUN=1
[[ " $* " == *" --force "* ]] && FORCE=1
mkdir -p ~/.architect/snapshots
