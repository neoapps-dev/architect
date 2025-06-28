pacstrapper() {
  local target="$1"
  local ARCHITECT_DIR="${2:-$ARCHITECT_DIR}"
  if [ -z "$target" ]; then
    echo "[!] architect --pacstrap <target_mount_point>"
    return 1
  fi

  if [ ! -d "$target" ]; then
    echo "[!] Target directory $target does not exist."
    return 1
  fi
  echo "[*] Starting pacstrap in $target..."
  sudo pacstrap -K "$target" ${packages_by_set[base]}
  echo "[*] Copying Architect config to $target$ARCHITECT_DIR ..."
  sudo mkdir -p "$target/$ARCHITECT_DIR"
  sudo cp -r "/etc/architect.sh" "$target/etc/architect.sh"
  if [ -d "$ARCHITECT_DIR/dotfiles" ]; then
    sudo cp -r "$ARCHITECT_DIR/dotfiles" "$target/$ARCHITECT_DIR/"
  fi
  echo "[*] Running post-install hooks inside chroot..."
  sudo arch-chroot "$target" /bin/bash -c "
    source /etc/architect.sh
    architect --apply-diff --no-snapshot
    post_install
  "
  echo "[+] Pacstrap complete in $target"
  exit
}
