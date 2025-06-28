diff() {
  echo "[*] Comparing current system to config..."]
  declare -A desired_pkgs
  for set in "${system_packages[@]}"; do
    for pkg in ${packages_by_set[$set]}; do
      desired_pkgs["$pkg"]=1
    done
  done
  declare -A current_pkgs
  while read -r name ver; do
    current_pkgs["$name"]="$ver"
  done < <(pacman -Q)
  for pkg in "${!desired_pkgs[@]}"; do
    if [[ -z "${current_pkgs[$pkg]}" ]]; then
      echo -e "\033[32m+ $pkg (not installed)\033[0m"
    elif [[ -n "${expected_versions[$pkg]}" && "${current_pkgs[$pkg]}" != "${expected_versions[$pkg]}" ]]; then
      echo -e "\033[33m~ $pkg (current: ${current_pkgs[$pkg]}, expected: ${expected_versions[$pkg]})\033[0m"
    fi
  done
  for pkg in "${!current_pkgs[@]}"; do
    if [[ -z "${desired_pkgs[$pkg]}" ]]; then
      echo -e "\033[31m- $pkg=${current_pkgs[$pkg]} (not in config)\033[0m"
    fi
  done
  exit
}

apply_diff() {
  echo "[*] Applying diff between current system and config..."
  [[ " $* " != *" --no-snapshot "* ]] && take_snapshot
  declare -A desired_pkgs
  declare -A expected_versions
  for set in "${system_packages[@]}"; do
    for pkg in ${packages_by_set[$set]}; do
      desired_pkgs["$pkg"]=1
      if [[ -n "${expected_versions_config[$pkg]}" ]]; then
        expected_versions["$pkg"]="${expected_versions_config[$pkg]}"
      fi
    done
  done
  declare -A current_pkgs
  while read -r name ver; do
    current_pkgs["$name"]="$ver"
  done < <(pacman -Q)
  to_install=()
  to_remove=()
  for pkg in "${!desired_pkgs[@]}"; do
    if [[ -z "${current_pkgs[$pkg]}" ]]; then
      if [[ -n "${expected_versions[$pkg]}" ]]; then
        to_install+=("${pkg}=${expected_versions[$pkg]}")
      else
        to_install+=("$pkg")
      fi
    elif [[ -n "${expected_versions[$pkg]}" && "${current_pkgs[$pkg]}" != "${expected_versions[$pkg]}" ]]; then
      to_install+=("${pkg}=${expected_versions[$pkg]}")
    fi
  done
  for pkg in "${!current_pkgs[@]}"; do
    if [[ -z "${desired_pkgs[$pkg]}" ]]; then
      to_remove+=("$pkg")
    fi
  done
  if [[ ${#to_install[@]} -gt 0 ]]; then
    echo "[+] Installing/upgrading: ${to_install[*]}"
    sudo pacman -S --noconfirm "${to_install[@]}"
  fi
  if [[ ${#to_remove[@]} -gt 0 ]]; then
    echo "[-] Removing: ${to_remove[*]}"
    sudo pacman -Rns --noconfirm "${to_remove[@]}"
  fi
  echo "[+] System synced with config (version-aware)."
}
