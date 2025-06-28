take_snapshot() {
  local snapfile="$ARCHITECT_DIR/snapshots/$(date +%Y%m%d-%H%M%S).pkglist"
  pacman -Q | awk '{print $1 "=" $2}' >"$snapfile"
  echo "[+] Snapshot saved: $snapfile"
}

list_snapshots() {
  echo "[?] Snapshots Available:"
  if ! ls -1 "$ARCHITECT_DIR/snapshots" &>/dev/null; then
    echo "No snapshots found."
    return
  fi
  ls -1 "$ARCHITECT_DIR/snapshots" | nl
  exit
}

purge_all_snapshots() {
  local dir="$ARCHITECT_DIR/snapshots"
  if [ ! -d "$dir" ]; then
    echo "[!] Snapshot dir not found: $dir"
    return 1
  fi
  if [ "$FORCE" != 1 ] && [ "$DRY_RUN" != 1 ]; then
    read -rp "[?] Really delete ALL snapshots? [y/N] " confirm
    [[ "$confirm" != [yY] ]] && echo "[x] Cancelled." && exit 1
  fi
  echo "[*] Purging all snapshots in $dir..."
  [ "$DRY_RUN" == 1 ] && echo "[+] [DRY RUN] rm -f \"$dir\"/*.pkglist" && exit
  rm -f "$dir"/*.pkglist
  echo "[+] Snapshots purged."
  exit
}

rollback() {
  echo "[*] Available snapshots:"
  ls -1 "$ARCHITECT_DIR/snapshots" | nl
  read -p "[*] Choose snapshot number to rollback: " num
  snap=$(ls "$ARCHITECT_DIR/snapshots" | sed -n "${num}p")
  [[ -z "$snap" ]] && echo "Invalid selection." && exit 1
  echo "[*] Restoring snapshot $snap"
  declare -A snapshot_pkgs
  while read -r line; do
    [[ -n "$line" ]] || continue
    local pkg_name="${line%%=*}"
    local pkg_ver="${line#*=}"
    snapshot_pkgs["$pkg_name"]="$pkg_ver"
  done <"$ARCHITECT_DIR/snapshots/$snap"
  local to_install=()
  for pkg in "${!snapshot_pkgs[@]}"; do
    if ! pacman -Qi "$pkg" &>/dev/null; then
      to_install+=("${pkg}=${snapshot_pkgs[$pkg]}")
    fi
  done
  [[ ${#to_install[@]} -gt 0 ]] && sudo pacman -S --noconfirm "${to_install[@]}"
  local current_pkgs=($(pacman -Qq))
  local to_remove=()
  for pkg in "${current_pkgs[@]}"; do
    if [[ -z "${snapshot_pkgs[$pkg]}" ]]; then
      to_remove+=("$pkg")
    fi
  done
  [[ ${#to_remove[@]} -gt 0 ]] && sudo pacman -Rns --noconfirm "${to_remove[@]}"
  echo "[+] System rolled back to snapshot: $snap"
  exit
}

purge_snapshots() {
  local dir="$ARCHITECT_DIR/snapshots"
  local keep=${1:-3}
  if [ ! -d "$dir" ]; then
    echo "[!] Snapshot dir not found: $dir"
    return 1
  fi
  echo "[*] Keeping last $keep snapshot(s), deleting older ones..."
  [ "$DRY_RUN" == 1 ] && echo "[+] [DRY RUN] rm -f:" && ls -1t "$dir"/*.pkglist | tail -n +$((keep + 1)) && exit
  ls -1t "$dir"/*.pkglist | tail -n +$((keep + 1)) | xargs -r rm -f
  echo "[+] Old snapshots purged."
  exit
}

take_snapshot_now() {
  take_snapshot
  exit
}
