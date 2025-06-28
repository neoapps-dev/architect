get_desired_pkgs() {
  local pkgs=()
  for set in "${system_packages[@]}"; do
    local pkg_list=()
    mapfile -t pkg_list <<<"${packages_by_set[$set]}"
    for pkg in "${pkg_list[@]}"; do
      [[ -z "$pkg" ]] && continue
      pkgs+=("$pkg")
    done
  done
  echo "${pkgs[@]}"
}

resolve_aur_packages() {
  local all_pkgs=()
  [[ ${#aur_packages[@]} -eq 0 ]] && return
  for set in "${aur_packages[@]}"; do
    [[ -n "${aur_packages_by_set[$set]}" ]] || continue
    for pkg in ${aur_packages_by_set[$set]}; do
      all_pkgs+=("$pkg")
    done
  done
  [[ ${#all_pkgs[@]} -eq 0 ]] && return
  printf '%s\n' "${all_pkgs[@]}" | sort -u | tr '\n' ' '
}

install_aur() {
  local pkgs
  pkgs=($(resolve_aur_packages))
  [[ ${#pkgs[@]} -eq 0 ]] && return
  for pkg in "${pkgs[@]}"; do
    echo "[*] Building AUR package: $pkg"
    local build_dir="/tmp/architect-build-$pkg"
    if [ "$DRY_RUN" = 1 ]; then
      echo "[DRY RUN] rm -rf $build_dir"
      echo "[DRY RUN] git clone https://aur.archlinux.org/$pkg.git $build_dir"
      echo "[DRY RUN] cd $build_dir && makepkg -si --noconfirm"
    else
      rm -rf "$build_dir"
      git clone "https://aur.archlinux.org/$pkg.git" "$build_dir"
      cd "$build_dir" && makepkg -si --noconfirm
    fi
  done
}

install_packages() {
  local pkgs
  pkgs=($(get_desired_pkgs))
  [[ ${#pkgs[@]} -eq 0 ]] && return
  echo "[*] Installing packages: ${pkgs[*]}"
  if [ "$DRY_RUN" = 1 ]; then
    echo "[DRY RUN] sudo pacman -Sy --noconfirm --needed ${pkgs[*]}"
  else
    sudo pacman -Sy --noconfirm --needed "${pkgs[@]}"
  fi
}

install() {
  echo "[*] Installing packages from config..."
  [[ " $* " != *" --no-snapshot "* ]] && take_snapshot
  install_packages
  install_aur
  echo "[*] Running post-install hooks..."
  post_install
  echo "[+] Installation complete"
  exit
}

remove_packages() {
  local desired=($(get_desired_pkgs))
  local installed=($(pacman -Qqent))
  local to_remove=()
  for pkg in "${installed[@]}"; do
    if [[ ! " ${desired[*]} " =~ " ${pkg} " ]]; then
      to_remove+=("$pkg")
    fi
  done
  if ((${#to_remove[@]})); then
    echo "[*] Packages to remove: ${to_remove[*]}"
    if ((DRY_RUN)); then
      echo "[DRY RUN] sudo pacman -Rns --noconfirm ${to_remove[*]}"
    else
      pre_remove
      sudo pacman -Rns --noconfirm "${to_remove[@]}"
    fi
  else
    echo "[+] No extra packages to remove."
  fi
}
