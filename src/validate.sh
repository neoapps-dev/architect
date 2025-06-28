validate_aur_package() {
  local pkg="$1"
  [[ -z "$pkg" ]] && return 1
  local res
  res=$(curl -s "https://aur.archlinux.org/rpc/?v=5&type=info&arg=$pkg")
  local count
  count=$(echo "$res" | grep -o '"resultcount":[0-9]*' | grep -o '[0-9]*')
  if [ "$count" -eq 1 ]; then
    echo "[+] AUR package '$pkg' found."
    return 0
  else
    echo "[!] AUR package '$pkg' NOT found."
    return 1
  fi
}

validate_all_aur_packages() {
  local pkgs
  pkgs=($(resolve_aur_packages))
  [[ ${#pkgs[@]} -eq 0 ]] && return 0
  local failed=0
  for pkg in "${pkgs[@]}"; do
    validate_aur_package "$pkg" || failed=1
  done
  return $failed
}

validate_config() {
  echo "[*] Validating config file: $CONFIG_FILE"
  if [ ! -f "$CONFIG_FILE" ]; then
    echo "[!] Config file not found: $CONFIG_FILE"
    exit 1
  fi
  if ! bash -n "$CONFIG_FILE"; then
    echo "[!] Syntax error in config file"
    exit 1
  fi
  for set in "${system_packages[@]}"; do
    local pkg_list=()
    mapfile -t pkg_list <<< "${packages_by_set[$set]}"
    for pkg in "${pkg_list[@]}"; do
      [[ -z "$pkg" ]] && continue
      if ! pacman -Si "$pkg" &>/dev/null; then
        echo "[!] Package '$pkg' not found in official repos"
      else
        echo "[+] Package '$pkg' found in official repos"
      fi
    done
  done
  if ! validate_all_aur_packages; then
    echo "[!] Some AUR packages failed validation."
    exit 1
  fi
  echo "[+] Config validation completed"
  exit 0
}
