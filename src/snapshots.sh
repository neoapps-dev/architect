take_snapshot() {
  local snapfile=~/.architect/snapshots/$(date +%Y%m%d-%H%M%S).pkglist
  pacman -Q | awk '{print $1 "=" $2}' >"$snapfile"
  echo "[+] Snapshot saved: $snapfile"
}

list_snapshots() {
  echo "[?] Snapshots Available:"
  if ! ls -1 ~/.architect/snapshots &>/dev/null; then
    echo "No snapshots found."
    return
  fi

  ls -1 ~/.architect/snapshots | nl
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
  ls -1 ~/.architect/snapshots | nl
  read -p "[*] Choose snapshot number to rollback: " num
  snap=$(ls ~/.architect/snapshots | sed -n "${num}p")
  [[ -z $snap ]] && echo "Invalid selection." && exit 1
  echo "[*] Restoring snapshot $snap"
  mapfile -t pkgs_to_install <~/.architect/snapshots/$snap
  sudo pacman -S --noconfirm "${pkgs_to_install[@]}"
  pkgstemp=()
  for pv in "${pkgs_to_install[@]}"; do
    pkgstemp+=("${pv%% *}")
  done
  current_pkgs=$(pacman -Qq)
  for pkg in $current_pkgs; do
    if [[ ! " ${pkgs_to_install[*]} " =~ " $pkg " ]]; then
      sudo pacman -Rns --noconfirm "$pkg"
    fi
  done
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
