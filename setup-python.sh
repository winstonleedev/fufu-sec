#!/bin/bash
# setup.sh — Install required Python and system packages for fufu-sec
# Usage: sudo ./setup.sh

set -e

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
info()  { echo -e "${GREEN}[+]${NC} $*"; }
warn()  { echo -e "${YELLOW}[!]${NC} $*"; }
error() { echo -e "${RED}[-]${NC} $*"; exit 1; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
info "fufu-sec dir: $SCRIPT_DIR"

# ── Local Python venv (stays inside this folder) ─────────────────────────────
VENV="$SCRIPT_DIR/.venv"
[[ ! -d "$VENV" ]] && python3 -m venv "$VENV" && info "Created .venv"
"$VENV/bin/pip" install --quiet --upgrade flask flask-cors
info "Flask installed in .venv"

# ── Runtime dirs ─────────────────────────────────────────────────────────────
mkdir -p /tmp/fufu-sec "$SCRIPT_DIR/logs"


# --- Python dependencies (for server.py) ---
PYTHON_REQS=(flask flask_cors)

# --- System tools required (ESSENTIAL_TOOLS + common wireless/cracking tools) ---
SYSTEM_REQS=(
  iw awk ip ps
  airmon-ng airodump-ng aircrack-ng aireplay-ng
  mdk4 hostapd dnsmasq
  reaver bully pixiewps
  hashcat john crunch64
  hcxpcapngtool hcxdumptool tshark tcpdump
)

# --- Install Python packages ---
echo "[+] Installing Python dependencies..."
$VENV/bin/pip install --upgrade pip
$VENV/bin/pip install "${PYTHON_REQS[@]}"

echo "[+] Setup complete."

echo ""
info "Done. To start fufu-sec:"
echo ""
echo "    cd $SCRIPT_DIR"
echo "    sudo $VENV/bin/python3 server.py"
echo ""
echo "    Open  http://localhost:5000  in your browser."
echo ""
warn "To uninstall: delete the fufu-sec folder. Nothing was installed globally."