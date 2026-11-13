#!/usr/bin/env bash
# ==============================================================================
# PenguTunnel Fast One-Click Installer & Runner (GitHub Direct / Global)
# Repository: https://github.com/theneet0/PenguTunnel
# Mirror: GitHub Direct (Global High-Speed)
# Version: 5.4.1 (Offline Fix 1)
# ==============================================================================

# Root check
if [[ -z "${BYPASS_ROOT_CHECK:-}" && ${EUID:-$(id -u)} -ne 0 ]]; then
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

# Parse mirror arguments if passed to run.sh
PASSED_ARGS=()
for arg in "$@"; do
  case "$arg" in
    --cdn|--jsdelivr) PENGU_MIRROR="cdn" ;;
    --iran|--ghproxy) PENGU_MIRROR="iran" ;;
    --github|--direct) PENGU_MIRROR="github" ;;
    --mirror=*) PENGU_MIRROR="${arg#*=}" ;;
    *) PASSED_ARGS+=("$arg") ;;
  esac
done

if [[ -z "${PENGU_MIRROR:-}" && -f "${INSTALL_DIR}/.mirror" ]]; then
  PENGU_MIRROR="$(cat "${INSTALL_DIR}/.mirror" 2>/dev/null | tr -d ' \r\n' || true)"
fi
PENGU_MIRROR="${PENGU_MIRROR:-github}"
export PENGU_MIRROR
echo "$PENGU_MIRROR" > "${INSTALL_DIR}/.mirror" 2>/dev/null || true

# Install prerequisites if missing
install_deps() {
  local pkgs=()
  command -v curl >/dev/null 2>&1 || pkgs+=(curl)
  command -v wget >/dev/null 2>&1 || pkgs+=(wget)
  command -v gzip >/dev/null 2>&1 || pkgs+=(gzip)
  command -v sha256sum >/dev/null 2>&1 || pkgs+=(coreutils)
  if [[ ${#pkgs[@]} -gt 0 ]]; then
    echo -e "\033[36m[*] Installing prerequisites: ${pkgs[*]}...\033[0m"
    if command -v apt-get >/dev/null 2>&1; then
      DEBIAN_FRONTEND=noninteractive apt-get update -qq >/dev/null 2>&1 || true
      DEBIAN_FRONTEND=noninteractive apt-get install -y -qq "${pkgs[@]}" >/dev/null 2>&1 || true
    elif command -v dnf >/dev/null 2>&1; then
      dnf install -y -q "${pkgs[@]}" >/dev/null 2>&1 || true
    elif command -v yum >/dev/null 2>&1; then
      yum install -y -q "${pkgs[@]}" >/dev/null 2>&1 || true
    fi
  fi
}
install_deps

# Helper for download with appropriate progress display & timeouts
download_file() {
  local url="$1"
  local output="$2"
  local timeout="${3:-300}"

  if command -v curl >/dev/null 2>&1; then
    if [[ -t 1 || -t 2 ]]; then
      curl -fL --connect-timeout 6 --max-time "$timeout" --retry 2 --progress-bar "$url" -o "$output"
    else
      curl -fsSL --connect-timeout 6 --max-time "$timeout" --retry 2 "$url" -o "$output"
    fi
  elif command -v wget >/dev/null 2>&1; then
    if [[ -t 1 || -t 2 ]]; then
      wget -q --show-progress --connect-timeout=6 --timeout="$timeout" --tries=2 "$url" -O "$output"
    else
      wget -q --connect-timeout=6 --timeout="$timeout" --tries=2 "$url" -O "$output"
    fi
  else
    return 1
  fi
}

# Check core binary
need_core_dl=1
if [[ -f "$BIN_PATH" ]]; then
  curr_sha="$(sha256sum "$BIN_PATH" 2>/dev/null | awk '{print $1}')"
  if [[ "$curr_sha" == "$OFFLINE_SHA256" ]]; then
    need_core_dl=0
  fi
fi

if [[ $need_core_dl -eq 1 ]]; then
  CORE_URLS=()
  case "$PENGU_MIRROR" in
    cdn|jsdelivr)
      echo -e "\033[36m[*] Dedicated jsDelivr CDN Mirror Active\033[0m"
      echo -e "\033[36m[*] Downloading PenguTunnel v5.4.1 core via jsDelivr CDN...\033[0m"
      CORE_URLS=(
        "https://cdn.jsdelivr.net/gh/theneet0/PenguTunnel@main/pengutunnel.gz"
        "https://cdn.jsdelivr.net/gh/theneet0/PenguTunnel@main/pengutunnel"
        "https://gh-proxy.com/https://raw.githubusercontent.com/theneet0/PenguTunnel/main/pengutunnel.gz"
        "https://gh-proxy.com/https://raw.githubusercontent.com/theneet0/PenguTunnel/main/pengutunnel"
        "https://ghproxy.net/https://raw.githubusercontent.com/theneet0/PenguTunnel/main/pengutunnel"
        "https://github.com/theneet0/PenguTunnel/releases/download/v5.4.1/pengutunnel.gz"
        "https://github.com/theneet0/PenguTunnel/releases/download/v5.4.1/pengutunnel"
        "https://raw.githubusercontent.com/theneet0/PenguTunnel/main/pengutunnel"
      )
      ;;
    iran|ghproxy)
      echo -e "\033[36m[*] Dedicated Iran / GhProxy Mirror Active\033[0m"
      echo -e "\033[36m[*] Downloading PenguTunnel v5.4.1 core via Iran GhProxy mirror...\033[0m"
      CORE_URLS=(
        "https://gh-proxy.com/https://raw.githubusercontent.com/theneet0/PenguTunnel/main/pengutunnel.gz"
        "https://gh-proxy.com/https://raw.githubusercontent.com/theneet0/PenguTunnel/main/pengutunnel"
        "https://cdn.jsdelivr.net/gh/theneet0/PenguTunnel@main/pengutunnel.gz"
        "https://cdn.jsdelivr.net/gh/theneet0/PenguTunnel@main/pengutunnel"
        "https://gh-proxy.com/https://github.com/theneet0/PenguTunnel/releases/download/v5.4.1/pengutunnel.gz"
        "https://gh-proxy.com/https://github.com/theneet0/PenguTunnel/releases/download/v5.4.1/pengutunnel"
        "https://ghproxy.net/https://raw.githubusercontent.com/theneet0/PenguTunnel/main/pengutunnel"
        "https://raw.githubusercontent.com/theneet0/PenguTunnel/main/pengutunnel"
        "https://github.com/theneet0/PenguTunnel/releases/download/v5.4.1/pengutunnel"
      )
      ;;
    *)
      echo -e "\033[36m[*] Downloading PenguTunnel v5.4.1 core (~44MB)...\033[0m"
      CORE_URLS=(
        "https://github.com/theneet0/PenguTunnel/releases/download/v5.4.1/pengutunnel.gz"
        "https://github.com/theneet0/PenguTunnel/releases/download/v5.4.1/pengutunnel"
        "https://raw.githubusercontent.com/theneet0/PenguTunnel/main/pengutunnel.gz"
        "https://raw.githubusercontent.com/theneet0/PenguTunnel/main/pengutunnel"
        "https://cdn.jsdelivr.net/gh/theneet0/PenguTunnel@main/pengutunnel.gz"
        "https://cdn.jsdelivr.net/gh/theneet0/PenguTunnel@main/pengutunnel"
        "https://gh-proxy.com/https://raw.githubusercontent.com/theneet0/PenguTunnel/main/pengutunnel.gz"
        "https://gh-proxy.com/https://raw.githubusercontent.com/theneet0/PenguTunnel/main/pengutunnel"
        "https://ghproxy.net/https://raw.githubusercontent.com/theneet0/PenguTunnel/main/pengutunnel"
      )
      ;;
  esac

  core_success=0
  for url in "${CORE_URLS[@]}"; do
    echo -e "\033[33m[>] Trying mirror: ${url}\033[0m"
    rm -f "${BIN_PATH}.tmp"
    if download_file "$url" "${BIN_PATH}.tmp" 300; then
      if [[ "$url" == *.gz ]]; then
        if command -v gzip >/dev/null 2>&1; then
          gzip -dc "${BIN_PATH}.tmp" > "${BIN_PATH}.tmp.dec" 2>/dev/null && mv -f "${BIN_PATH}.tmp.dec" "${BIN_PATH}.tmp" || true
        fi
      fi
      downloaded_sha="$(sha256sum "${BIN_PATH}.tmp" 2>/dev/null | awk '{print $1}')"
      if [[ "$downloaded_sha" == "$OFFLINE_SHA256" ]]; then
        mv -f "${BIN_PATH}.tmp" "$BIN_PATH"
        chmod +x "$BIN_PATH" 2>/dev/null || true
        echo -e "\033[32m[ok] PenguTunnel core verified successfully (SHA256: ${OFFLINE_SHA256:0:16}...).\033[0m"
        core_success=1
        break
      else
        echo -e "\033[31m[!] Checksum mismatch for ${url}, trying next mirror...\033[0m"
        rm -f "${BIN_PATH}.tmp"
      fi
    else
      echo -e "\033[33m[!] Connection failed for ${url}, trying next mirror...\033[0m"
      rm -f "${BIN_PATH}.tmp"
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
SCRIPT_URLS=()
case "$PENGU_MIRROR" in
  cdn|jsdelivr)
    SCRIPT_URLS=(
      "https://cdn.jsdelivr.net/gh/theneet0/PenguTunnel@main/install.sh"
      "https://cdn.jsdelivr.net/gh/theneet0/PenguTunnel@v5.4.1/install.sh"
      "https://gh-proxy.com/https://raw.githubusercontent.com/theneet0/PenguTunnel/main/install.sh"
      "https://ghproxy.net/https://raw.githubusercontent.com/theneet0/PenguTunnel/main/install.sh"
      "https://raw.githubusercontent.com/theneet0/PenguTunnel/main/install.sh"
    )
    ;;
  iran|ghproxy)
    SCRIPT_URLS=(
      "https://gh-proxy.com/https://raw.githubusercontent.com/theneet0/PenguTunnel/main/install.sh"
      "https://cdn.jsdelivr.net/gh/theneet0/PenguTunnel@main/install.sh"
      "https://ghproxy.net/https://raw.githubusercontent.com/theneet0/PenguTunnel/main/install.sh"
      "https://raw.githubusercontent.com/theneet0/PenguTunnel/main/install.sh"
    )
    ;;
  *)
    SCRIPT_URLS=(
      "https://raw.githubusercontent.com/theneet0/PenguTunnel/main/install.sh"
      "https://github.com/theneet0/PenguTunnel/releases/download/v5.4.1/install.sh"
      "https://cdn.jsdelivr.net/gh/theneet0/PenguTunnel@main/install.sh"
      "https://gh-proxy.com/https://raw.githubusercontent.com/theneet0/PenguTunnel/main/install.sh"
      "https://ghproxy.net/https://raw.githubusercontent.com/theneet0/PenguTunnel/main/install.sh"
    )
    ;;
esac

script_success=0
for url in "${SCRIPT_URLS[@]}"; do
  rm -f "${SCRIPT_PATH}.tmp"
  if download_file "$url" "${SCRIPT_PATH}.tmp" 30; then
    if bash -n "${SCRIPT_PATH}.tmp" >/dev/null 2>&1; then
      mv -f "${SCRIPT_PATH}.tmp" "$SCRIPT_PATH"
      chmod +x "$SCRIPT_PATH" 2>/dev/null || true
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
create_shortcut() {
  for bin_dir in /usr/local/bin /usr/bin; do
    if [[ -d "$bin_dir" && -w "$bin_dir" ]]; then
      cat << 'EOF_PENGU' > "${bin_dir}/pengu" 2>/dev/null || continue
#!/usr/bin/env bash
cd /root/pengutunnel && exec bash install.sh "$@"
EOF_PENGU
      chmod +x "${bin_dir}/pengu" 2>/dev/null || true
      ln -sf "${bin_dir}/pengu" "${bin_dir}/pengutunnel" 2>/dev/null || true
      break
    fi
  done
}
create_shortcut

echo -e "\033[32m[ok] Setup completed! Shortcuts 'pengu' and 'pengutunnel' are active.\033[0m"

# Safe execution of install.sh
if [[ -t 0 ]]; then
  exec bash "$SCRIPT_PATH" "${PASSED_ARGS[@]}"
elif ( : < /dev/tty ) 2>/dev/null; then
  exec bash "$SCRIPT_PATH" "${PASSED_ARGS[@]}" < /dev/tty
elif [[ ${#PASSED_ARGS[@]} -gt 0 ]]; then
  exec bash "$SCRIPT_PATH" "${PASSED_ARGS[@]}"
else
  echo -e "\033[36m[*] Interactive terminal not detected (headless or pipe session).\033[0m"
  echo -e "\033[32m[ok] Core binary and installer are installed at ${INSTALL_DIR}.\033[0m"
  echo -e "\033[36m[*] Run \033[1;37mpengu\033[0m\033[36m in an interactive terminal to open the tunnel menu.\033[0m"
  exit 0
fi
