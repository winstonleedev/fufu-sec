#!/usr/bin/env bash
# fufu-sec — local installer
# Sets up a local venv. Nothing is installed globally.
# Delete this folder to uninstall completely.
# Usage: sudo bash install.sh

set -e

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
info()  { echo -e "${GREEN}[+]${NC} $*"; }
warn()  { echo -e "${YELLOW}[!]${NC} $*"; }
error() { echo -e "${RED}[-]${NC} $*"; exit 1; }

[[ $EUID -ne 0 ]] && error "Run as root: sudo bash install.sh"
command -v pacman &>/dev/null || error "pacman not found. Requires Arch Linux or an Arch-based distro."

AUR_HELPER=""
if command -v yay &>/dev/null; then
    AUR_HELPER="yay"
elif command -v paru &>/dev/null; then
    AUR_HELPER="paru"
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
info "fufu-sec dir: $SCRIPT_DIR"

install_aur_package() {
    local pkg="$1"
    if [[ -n "$AUR_HELPER" ]]; then
        info "Installing $pkg from AUR via $AUR_HELPER..."
        "$AUR_HELPER" -S --noconfirm --needed "$pkg"
    else
        warn "AUR helper not found; cannot install $pkg from AUR."
        return 1
    fi
}

# ── System packages ───────────────────────────────────────────────────────────
info "Installing system packages..."
yay -Sy --noconfirm
yay -S --needed --noconfirm \
    iw wireless_tools net-tools \
    aircrack-ng \
    reaver bully pixiewps \
    hcxdumptool hcxtools \
    mdk4 \
    tcpdump wireshark-cli \
    hashcat crunch64 \
    hostapd dnsmasq iptables

if ! yay -S --needed --noconfirm wordlists 2>/dev/null; then
    warn "wordlists package not available in the official repos."
    install_aur_package wordlists john-git || warn "Install rockyou manually or add an AUR helper."
fi

# ── Rockyou ──────────────────────────────────────────────────────────────────
[[ -f /usr/share/wordlists/rockyou.txt.gz && ! -f /usr/share/wordlists/rockyou.txt ]] && \
    gunzip /usr/share/wordlists/rockyou.txt.gz && info "rockyou.txt decompressed"

