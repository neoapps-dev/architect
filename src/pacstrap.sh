pacstrapper() {
  local target="$1"
  local arch_dir="${2:-$ARCHITECT_DIR}"
  [[ -z $target ]] && {
    echo "[!] Usage: architect --pacstrap <target_mount_point>"
    exit 1
  }
  [[ ! -d $target ]] && {
    echo "[!] Target directory $target does not exist."
    exit 1
  }
  local pkgs=()
  for set in "${system_packages[@]}"; do
    pkgs+=(${packages_by_set[$set]})
  done
  echo "[*] Starting pacstrap in $target..."
  sudo pacstrap -K "$target" "${pkgs[@]} sudo"
  echo "[*] Copying Architect config and dotfiles..."
  sudo mkdir -p "$target/$arch_dir"
  sudo cp "/etc/architect.sh" "$target/etc/architect.sh"
  [[ -d $arch_dir/dotfiles ]] && sudo cp -r "$arch_dir/dotfiles" "$target/$arch_dir/"
  echo "[*] Copying Architect executable..."
  local arch_src="${ARCHITECT_PATH:-$(realpath "$0")}"
  sudo cp "$arch_src" "$target/usr/local/bin/architect"
  sudo chmod +x "$target/usr/local/bin/architect"
  echo "[*] Running post-install hooks inside chroot..."
  sudo arch-chroot "$target" /bin/bash -c '
    source /etc/architect.sh
    architect --apply-diff --no-snapshot
    post_install
  '
  echo "[+] Pacstrap complete in $target"
  exit
}
