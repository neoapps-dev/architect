sync_dotfiles() {
  local src_dir="${1:-$ARCHITECT_DIR/dotfiles}"
  [[ ${#dotfiles[@]} -eq 0 ]] && {
    echo "[!] No dotfiles defined in config"
    exit 1
  }
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
  [[ ${#dotfiles[@]} -eq 0 ]] && {
    echo "[!] No dotfiles defined in config"
    exit 1
  }
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

git_status_dotfiles() {
  local src_dir="${1:-$ARCHITECT_DIR/dotfiles}"
  if [ ! -d "$src_dir/.git" ]; then
    echo "[x] Dotfiles repo not initialized."
    echo "[x] Use --dotfiles-git-init"
    exit 1
  fi
  cd "$src_dir" || return 1
  git status --short --branch
  exit
}

git_init_dotfiles() {
  local src_dir="${1:-$ARCHITECT_DIR/dotfiles}"
  echo "[*] Initializing dotfiles git repo at $src_dir"
  mkdir -p "$src_dir"
  cd "$src_dir"
  git init
  echo "[+] Dotfiles git repo initialized."
  exit
}

commit_dotfiles() {
  local src_dir="${1:-$ARCHITECT_DIR/dotfiles}"
  local msg="${2:-No commit message}"
  local temp_config="$src_dir/$(basename "$CONFIG_FILE")"
  echo "[*] Committing dotfiles with message: $msg"
  cd "$src_dir" || {
    if [ "$src_dir" = "--include-config" ]; then
      echo "[*] Found --include-config. Retrying..."
      commit_dotfiles "${3:-$ARCHITECT_DIR/dotfiles}" "$msg"
      exit
    fi
    echo "[x] Failed to enter $src_dir"
    exit
  }
  git add .
  if [ "$INCLUDE_CONFIG" = "1" ] && [ -n "$CONFIG_FILE" ] && [ -f "$CONFIG_FILE" ]; then
    cp "$CONFIG_FILE" "$temp_config"
    git add "$(basename "$CONFIG_FILE")"
  fi
  git commit -m "$msg"
  if [ "$INCLUDE_CONFIG" = "1" ] && [ -n "$CONFIG_FILE" ] && [ -f "$temp_config" ]; then
    rm -f "$temp_config"
  fi
  echo "[+] Dotfiles committed."
  exit
}

push_dotfiles() {
  local src_dir="${1:-$ARCHITECT_DIR/dotfiles}"
  echo "[*] Pushing dotfiles repo to remote"
  cd "$src_dir" || {
    echo "[x] Failed to enter $src_dir"
    exit
  }
  local remote
  remote=$(git remote)
  if [ -z "$remote" ]; then
    echo "[x] No remote set. Use --dotfiles-set-url to add one."
    exit
  fi
  local branch
  branch=$(git symbolic-ref --short HEAD 2>/dev/null || echo "master")
  git push --set-upstream origin "$branch"
  echo "[+] Dotfiles pushed."
  exit
}

set_url_dotfiles() {
  local url="$1"
  local src_dir="${2:-$ARCHITECT_DIR/dotfiles}"
  if [ -z "$url" ]; then
    echo "[x] Remote URL required."
    exit
  fi
  echo "[*] Setting remote URL to $url"
  cd "$src_dir" || {
    echo "[x] Failed to enter $src_dir"
    exit
  }
  local remote
  remote=$(git remote)
  if [ -z "$remote" ]; then
    git remote add origin "$url"
  else
    git remote set-url origin "$url"
  fi
  echo "[+] Remote URL set."
  exit
}
