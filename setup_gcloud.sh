#!/usr/bin/env bash

# Termux Google Cloud SDK Setup Script
# Created BY Daniel Kopret

echo "[-] Updating system packages..."
pkg update -y && pkg upgrade -y
pkg install python curl binutils tar -y

echo "[-] Downloading Google Cloud SDK installer..."
curl -O https://sdk.cloud.google.com

echo "[-] Installing SDK to $HOME/google-cloud-sdk..."
# Using --no-standard-compliance to ignore the ARM-specific component errors
bash sdk.cloud.google.com --install-dir=$HOME --no-standard-compliance --disable-prompts

# Shell detection
if [ -n "$ZSH_VERSION" ] || [ -f "$HOME/.zshrc" ]; then
    CONF_FILE="$HOME/.zshrc"
    echo "[-] Detected ZSH environment."
else
    CONF_FILE="$HOME/.bashrc"
    echo "[-] Detected BASH environment."
fi

echo "[-] Configuring environment in $CONF_FILE..."
if ! grep -q "google-cloud-sdk/bin" "$CONF_FILE"; then
    echo 'export PATH="$PATH:$HOME/google-cloud-sdk/bin"' >> "$CONF_FILE"
fi

# Create the 'gcs' shortcut alias
if ! grep -q "alias gcs=" "$CONF_FILE"; then
    echo "alias gcs='gcloud cloud-shell ssh'" >> "$CONF_FILE"
fi

echo "[-] Activating changes..."
export PATH="$PATH:$HOME/google-cloud-sdk/bin"

echo "------------------------------------------------------------"
echo "INSTALLATION COMPLETE | Created BY Daniel Kopret"
echo "------------------------------------------------------------"
echo "Starting Authentication..."
echo "1. Copy the link below to your browser."
echo "2. Copy the Verification Code and paste it back here."
echo "------------------------------------------------------------"

# The winning command combination
$HOME/google-cloud-sdk/bin/gcloud auth login --no-launch-browser --quiet

echo "[-] Setup finished! You can now use the command 'gcs' to enter Cloud Shell."
echo "[-] Please restart Termux or run: source $CONF_FILE"
