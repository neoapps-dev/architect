get_desired_pkgs() {
  local pkgs=()
  for set in "${system_packages[@]}"; do
    for pkg in ${packages_by_set[$set]}; do
      pkgs+=("$pkg")
    done
  done
  echo "${pkgs[@]}"
}

resolve_aur_packages() {
  local all_pkgs=()
  for set in "${aur_packages[@]}"; do
    for pkg in ${aur_packages_by_set[$set]}; do
      all_pkgs+=("$pkg")
    done
  done
  echo "${all_pkgs[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '
}

install_aur() {
  local pkgs
  pkgs=($(resolve_aur_packages))
  for pkg in "${pkgs[@]}"; do
    echo "[*] Building AUR package: $pkg"
    local build_dir="/tmp/architect-build-$pkg"
    if [ "$DRY_RUN" = 1 ]; then
      echo "[DRY RUN] rm -rf $build_dir"
      echo "[DRY RUN] git clone https://aur.archlinux.org/$pkg.git $build_dir"
      echo "[DRY RUN] cd $build_dir && makepkg -si --noconfirm"
      continue
    fi

    rm -rf "$build_dir"
    git clone "https://aur.archlinux.org/$pkg.git" "$build_dir" || {
      echo "[!] Failed to clone $pkg"
      continue
    }
    (cd "$build_dir" && makepkg -si --noconfirm) || {
      echo "[!] Failed to build/install $pkg"
      continue
    }
  done
}

install_packages() {
  local desired=($(get_desired_pkgs))
  local to_install=()
  for pkg in "${desired[@]}"; do
    if ! pacman -Qi "$pkg" &>/dev/null; then
      to_install+=("$pkg")
    fi
  done

  if ((${#to_install[@]})); then
    if ((DRY_RUN)); then
      echo "[DRY RUN] sudo pacman -S --noconfirm ${to_install[*]}"
      echo "[DRY RUN] git clone and makepkg -si for all AUR packages."
    else
      [[ " $* " != *" --no-snapshot "* ]] && take_snapshot
      sudo pacman -S --noconfirm "${to_install[@]}"
      echo "[*] Installing AUR packages..."
      install_aur
    fi
  else
    echo "[+] All desired packages already installed."
  fi
}

remove_packages() {
  local desired=($(get_desired_pkgs))
  local installed=($(pacman -Qq))
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
