sync_dotfiles() {
  local src_dir="${1:-$ARCHITECT_DIR/dotfiles}"
  for name in "${!dotfiles[@]}"; do
    local src="$src_dir/$name"
    local target="${dotfiles[$name]}"
    if [ ! -e "$src" ]; then
      echo "[!] Source dotfile missing: $src"
      continue
    fi
    if [ -L "$target" ] || [ -e "$target" ]; then
      rm -rf "$target"
    fi

    ln -s "$src" "$target"
    echo "[+] Linked $src -> $target"
  done
  exit
}

status_dotfiles() {
  local src_dir="${1:-$ARCHITECT_DIR/dotfiles}"
  printf "%-20s %-40s %-10s\n" "Dotfile" "Target Path" "Status"
  for name in "${!dotfiles[@]}"; do
    local src="$src_dir/$name"
    local target="${dotfiles[$name]}"
    local status="missing source"
    if [ ! -e "$src" ]; then
      status="missing source"
    elif [ ! -e "$target" ]; then
      status="missing target"
    elif [ -L "$target" ]; then
      if [ "$(readlink "$target")" = "$src" ]; then
        status="linked"
      else
        status="linked elsewhere"
      fi
    else
      status="exists but not symlink"
    fi
    printf "%-20s %-40s %-10s\n" "$name" "$target" "$status"
  done
  exit
}

edit_dotfile() {
  local name="$1"
  local src_dir="${2:-$ARCHITECT_DIR/dotfiles}"
  local src="$src_dir/$name"
  if [ -z "$name" ]; then
    echo "[!] architect --dotfiles-edit <name>"
    return 1
  fi
  if [ ! -e "$src" ]; then
    echo "[!] Dotfile source not found: $src"
    return 1
  fi
  ${EDITOR:-nano} "$src"
  exit
}
