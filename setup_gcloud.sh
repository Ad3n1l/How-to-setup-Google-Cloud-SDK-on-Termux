#!/usr/bin/env bash
# =============================================================================
# setup_gcloud.sh — Google Cloud SDK Installer for Termux (ARM64)
# Author : Daniel Kopret (github.com/Ad3n1l)
# =============================================================================
# What this script does:
#   1. Installs required Termux packages
#   2. Downloads and installs the Google Cloud SDK
#   3. Configures PATH and a `gcs` shortcut alias in your shell config
#   4. Authenticates you via browser-based login (no credential manager needed)
# =============================================================================

set -e  # Exit immediately on any error

# ── Colours ──────────────────────────────────────────────────────────────────
RESET="\033[0m"
BOLD="\033[1m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
CYAN="\033[0;36m"
RED="\033[0;31m"

info()    { echo -e "${CYAN}[*]${RESET} $1"; }
success() { echo -e "${GREEN}[✓]${RESET} $1"; }
warn()    { echo -e "${YELLOW}[!]${RESET} $1"; }
error()   { echo -e "${RED}[✗]${RESET} $1"; exit 1; }

# ── Banner ───────────────────────────────────────────────────────────────────
echo -e "${BOLD}"
echo "  ┌─────────────────────────────────────────────┐"
echo "  │   Google Cloud SDK — Termux ARM64 Installer  │"
echo "  │              by Daniel Kopret                 │"
echo "  └─────────────────────────────────────────────┘"
echo -e "${RESET}"

# ── Step 1: Install dependencies ─────────────────────────────────────────────
info "Updating package lists and installing dependencies..."
pkg update -y && pkg upgrade -y
pkg install python curl binutils tar -y
success "Dependencies installed."

# ── Step 2: Download SDK installer ───────────────────────────────────────────
info "Downloading Google Cloud SDK installer..."
curl -O https://sdk.cloud.google.com
success "Installer downloaded."

# ── Step 3: Install SDK ───────────────────────────────────────────────────────
info "Installing SDK to $HOME/google-cloud-sdk ..."
# --no-standard-compliance : skips the gcloud-crc32c component that fails on ARM
# --disable-prompts        : non-interactive install
bash sdk.cloud.google.com \
    --install-dir="$HOME" \
    --no-standard-compliance \
    --disable-prompts
success "SDK installed."

# ── Step 4: Configure shell environment ──────────────────────────────────────
if [ -n "$ZSH_VERSION" ] || [ -f "$HOME/.zshrc" ]; then
    CONF_FILE="$HOME/.zshrc"
    info "Detected ZSH — writing config to $CONF_FILE"
else
    CONF_FILE="$HOME/.bashrc"
    info "Detected BASH — writing config to $CONF_FILE"
fi

# Add SDK to PATH
if ! grep -q "google-cloud-sdk/bin" "$CONF_FILE"; then
    echo '' >> "$CONF_FILE"
    echo '# Google Cloud SDK' >> "$CONF_FILE"
    echo 'export PATH="$PATH:$HOME/google-cloud-sdk/bin"' >> "$CONF_FILE"
    success "PATH updated in $CONF_FILE"
else
    warn "PATH entry already exists in $CONF_FILE — skipping."
fi

# Add `gcs` shortcut alias
if ! grep -q "alias gcs=" "$CONF_FILE"; then
    echo "alias gcs='gcloud cloud-shell ssh'" >> "$CONF_FILE"
    success "Alias 'gcs' added."
else
    warn "Alias 'gcs' already exists — skipping."
fi

# Activate for this session
export PATH="$PATH:$HOME/google-cloud-sdk/bin"

# ── Step 5: Authenticate ──────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}────────────────────────────────────────────────${RESET}"
echo -e "${BOLD}  AUTHENTICATION${RESET}"
echo -e "${BOLD}────────────────────────────────────────────────${RESET}"
echo ""
echo "  1. A URL will appear below."
echo "  2. Open it in your browser and sign in to Google."
echo "  3. Copy the verification code and paste it here."
echo ""

# --no-launch-browser : prints the auth URL instead of opening a browser
# --quiet             : disables the system credential manager lookup
#                       (critical fix for Termux — without this, auth crashes)
"$HOME/google-cloud-sdk/bin/gcloud" auth login \
    --no-launch-browser \
    --quiet

# ── Done ──────────────────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}────────────────────────────────────────────────${RESET}"
success "Setup complete!"
echo ""
echo "  • Type ${BOLD}gcs${RESET} to SSH into Google Cloud Shell."
echo "  • Restart Termux or run: ${BOLD}source $CONF_FILE${RESET}"
echo ""
