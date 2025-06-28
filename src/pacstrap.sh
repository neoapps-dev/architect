pacstrapper() {
  local target="$1"
  local ARCH_DIR="${2:-$ARCHITECT_DIR}"
  if [[ -z "$target" ]]; then
    echo "[!] Usage: architect --pacstrap <target_mount_point>"
    exit 1
  fi
  if [[ ! -d "$target" ]]; then
    echo "[!] Target directory $target does not exist."
    exit 1
  fi
  echo "[*] Starting pacstrap in $target..."
  sudo pacstrap -K "$target" ${packages_by_set[base]}
  echo "[*] Copying Architect config and dotfiles to target..."
  sudo mkdir -p "$target/$ARCH_DIR"
  sudo cp "/etc/architect.sh" "$target/etc/architect.sh"
  if [[ -d "$ARCH_DIR/dotfiles" ]]; then
    sudo cp -r "$ARCH_DIR/dotfiles" "$target/$ARCH_DIR/"
  fi
  echo "[*] Copying Architect executable/script to target..."
  local arch_src="${ARCHITECT_PATH:-$(realpath "$0")}"
  sudo cp "$arch_src" "$target/usr/local/bin/architect"
  sudo chmod +x "$target/usr/local/bin/architect"
  echo "[*] Running post-install hooks inside chroot..."
  sudo arch-chroot "$target" /bin/bash -c "
    source /etc/architect.sh
    architect --apply-diff --no-snapshot
    post_install
  "
  echo "[+] Pacstrap complete in $target"
  exit
}
