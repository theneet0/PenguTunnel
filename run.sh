#!/usr/bin/env bash
# ==============================================================================
# PenguTunnel Fast One-Click Installer & Runner
# Repository: https://github.com/theneet0/PenguTunnel
# Version: 5.4.1 (Offline Fix 1)
# ==============================================================================

# Reconnect stdin if running inside curl | bash pipe
[[ -t 0 ]] || exec < /dev/tty 2>/dev/null || true

# Root check
if [[ $EUID -ne 0 ]]; then
  echo -e "\033[31m[x] Error: This script must be run as root (sudo bash).\033[0m" >&2
  exit 1
fi

# Architecture check
ARCH="$(uname -m)"
if [[ "$ARCH" != "x86_64" && "$ARCH" != "amd64" ]]; then
  echo -e "\033[31m[x] Error: Only Linux amd64 / x86_64 is supported.\033[0m" >&2
  exit 1
fi

set -eo pipefail

INSTALL_DIR="/root/pengutunnel"
BIN_PATH="${INSTALL_DIR}/pengutunnel"
SCRIPT_PATH="${INSTALL_DIR}/install.sh"
OFFLINE_SHA256="e70f4c1612e936108bdb17f0d8515342699242cc977b9037ba4a442f0af477fa"

mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

# Install prerequisites if missing
install_deps() {
  local pkgs=()
  command -v curl >/dev/null 2>&1 || pkgs+=(curl)
  command -v wget >/dev/null 2>&1 || pkgs+=(wget)
  command -v sha256sum >/dev/null 2>&1 || pkgs+=(coreutils)
  if [ ${#pkgs[@]} -gt 0 ]; then
    echo -e "\033[36m[*] Installing prerequisites: ${pkgs[*]}...\033[0m"
    if command -v apt-get >/dev/null 2>&1; then
      apt-get update -qq && apt-get install -y -qq "${pkgs[@]}" >/dev/null 2>&1
    elif command -v yum >/dev/null 2>&1; then
      yum install -y -q "${pkgs[@]}" >/dev/null 2>&1
    fi
  fi
}
install_deps

# Check core binary
need_core_dl=1
if [[ -f "$BIN_PATH" ]]; then
  curr_sha="$(sha256sum "$BIN_PATH" 2>/dev/null | awk '{print $1}')"
  if [[ "$curr_sha" == "$OFFLINE_SHA256" ]]; then
    need_core_dl=0
  fi
fi

if [[ $need_core_dl -eq 1 ]]; then
  echo -e "\033[36m[*] Downloading PenguTunnel v5.4.1 core (~44MB)...\033[0m"
  CORE_URLS=(
    "https://github.com/theneet0/PenguTunnel/releases/download/v5.4.1/pengutunnel"
    "https://raw.githubusercontent.com/theneet0/PenguTunnel/main/pengutunnel"
    "https://ghproxy.net/https://github.com/theneet0/PenguTunnel/releases/download/v5.4.1/pengutunnel"
  )
  core_success=0
  for url in "${CORE_URLS[@]}"; do
    echo -e "\033[33m[>] Trying: ${url}\033[0m"
    if curl -fL --progress-bar "$url" -o "${BIN_PATH}.tmp" 2>/dev/null || wget -q --show-progress "$url" -O "${BIN_PATH}.tmp" 2>/dev/null; then
      downloaded_sha="$(sha256sum "${BIN_PATH}.tmp" 2>/dev/null | awk '{print $1}')"
      if [[ "$downloaded_sha" == "$OFFLINE_SHA256" ]]; then
        mv -f "${BIN_PATH}.tmp" "$BIN_PATH"
        chmod +x "$BIN_PATH"
        echo -e "\033[32m[ok] PenguTunnel core verified successfully.\033[0m"
        core_success=1
        break
      else
        echo -e "\033[31m[!] Checksum mismatch for ${url}, trying next mirror...\033[0m"
        rm -f "${BIN_PATH}.tmp"
      fi
    fi
  done

  if [[ $core_success -ne 1 ]]; then
    echo -e "\033[31m[x] Failed to download valid PenguTunnel core binary.\033[0m" >&2
    exit 1
  fi
else
  echo -e "\033[32m[ok] PenguTunnel core already present and verified.\033[0m"
fi

# Download/update install.sh
echo -e "\033[36m[*] Fetching latest installer menu script...\033[0m"
SCRIPT_URLS=(
  "https://raw.githubusercontent.com/theneet0/PenguTunnel/main/install.sh"
  "https://github.com/theneet0/PenguTunnel/releases/download/v5.4.1/install.sh"
  "https://ghproxy.net/https://raw.githubusercontent.com/theneet0/PenguTunnel/main/install.sh"
)
script_success=0
for url in "${SCRIPT_URLS[@]}"; do
  if curl -fsSL "$url" -o "${SCRIPT_PATH}.tmp" 2>/dev/null || wget -q "$url" -O "${SCRIPT_PATH}.tmp" 2>/dev/null; then
    if bash -n "${SCRIPT_PATH}.tmp" >/dev/null 2>&1; then
      mv -f "${SCRIPT_PATH}.tmp" "$SCRIPT_PATH"
      chmod +x "$SCRIPT_PATH"
      script_success=1
      break
    else
      rm -f "${SCRIPT_PATH}.tmp"
    fi
  fi
done

if [[ $script_success -ne 1 ]]; then
  if [[ ! -f "$SCRIPT_PATH" ]]; then
    echo -e "\033[31m[x] Failed to download installer script.\033[0m" >&2
    exit 1
  fi
fi

# Create global shortcut 'pengu' and 'pengutunnel'
cat << 'EOF_PENGU' > /usr/local/bin/pengu 2>/dev/null || true
#!/usr/bin/env bash
cd /root/pengutunnel && ./install.sh "$@"
EOF_PENGU
chmod +x /usr/local/bin/pengu 2>/dev/null || true
ln -sf /usr/local/bin/pengu /usr/local/bin/pengutunnel 2>/dev/null || true

echo -e "\033[32m[ok] Ready! Starting PenguTunnel menu...\033[0m"
echo -e "\033[36m[*] Shortcut created: you can now run 'pengu' anytime from anywhere.\033[0m"
sleep 1

exec bash "$SCRIPT_PATH" "$@"
