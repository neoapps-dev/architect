#!/usr/bin/env bash
set -e
VERSION=0.0.1-alpha
CONFIG_FILE="${ARCHITECT_CONFIG:-/etc/architect.sh}"
declare -A packages_by_set
declare -A aur_packages_by_set
declare -A expected_versions_config
declare -A dotfiles
if [[ -f "$CONFIG_FILE" ]]; then
  source "$CONFIG_FILE"
elif [[ " $* " != *" --make-config "* ]]; then
  echo "[!] Config file not found: $CONFIG_FILE" >&2
  exit 1
fi
DRY_RUN=0
FORCE=0
INCLUDE_CONFIG=0
ARCHITECT_DIR="${ARCHITECT_DIR:-$HOME/.architect}"
[[ " $* " == *" --dry-run "* ]] && DRY_RUN=1
[[ " $* " == *" --force "* ]] && FORCE=1
[[ " $* " == *" --include-config " ]] && INCLUDE_CONFIG=1
mkdir -p ~/.architect/snapshots
