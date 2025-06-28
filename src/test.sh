run_test() {
  echo "[*] Running Architect self-test..."
  if [[ -f "$CONFIG_FILE" ]]; then
    echo "[+] Config file found: $CONFIG_FILE"
  else
    echo "[-] Config file not found: $CONFIG_FILE"
    exit 1
  fi
  command -v pacman >/dev/null && echo "[+] pacman is available" || {
    echo "[-] pacman not found"
    exit 1
  }
  ping -q -c 1 archlinux.org >/dev/null 2>&1 && echo "[+] Internet connection is working" || {
    echo "[-] No internet"
    exit 1
  }
  [[ -d "$ARCHITECT_DIR/snapshots" ]] && echo "[+] Snapshots directory exists: $ARCHITECT_DIR/snapshots" || {
    echo "[-] Snapshots directory missing"
    exit 1
  }
  [[ -w "$CONFIG_FILE" ]] && echo "[+] Writable config: $CONFIG_FILE" || {
    echo "[-] Config is not writable: $CONFIG_FILE"
  }
  echo "[+] All checks passed!"
  exit
}
