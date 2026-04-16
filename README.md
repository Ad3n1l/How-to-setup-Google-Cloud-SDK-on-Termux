# Google Cloud CLI for Termux (ARM64)

> Install and authenticate the Google Cloud SDK on Android — no root, no desktop required.

**Author:** [Daniel Kopret](https://github.com/Ad3n1l)

---

## The Problem

Running `gcloud` on Termux has two well-known failure points:

| Issue | Cause |
|---|---|
| Install crashes on ARM | The `gcloud-crc32c` component has no ARM64 binary |
| Auth hangs or crashes | `gcloud` tries to reach a system credential manager that doesn't exist on Android |

This script fixes both.

---

## Quick Install

```bash
curl -sL https://raw.githubusercontent.com/Ad3n1l/[REPO_NAME]/main/setup_gcloud.sh | bash
```

> **Tip:** You can also host this as a [GitHub Gist](https://gist.github.com) and use its raw URL.

---

## What the Script Does

1. Installs required Termux packages (`python`, `curl`, `binutils`, `tar`)
2. Downloads the official Google Cloud SDK installer
3. Installs the SDK with `--no-standard-compliance` to skip the broken ARM component
4. Adds the SDK to your `PATH` in `.zshrc` or `.bashrc` (auto-detected)
5. Adds a `gcs` shortcut alias for quick Cloud Shell access
6. Authenticates you using the two critical flags:

```bash
gcloud auth login --no-launch-browser --quiet
```

### Why `--quiet`?

This is the key fix. Without `--quiet`, `gcloud` attempts to access a system-level
credential manager (e.g. GNOME Keyring) during login. That component doesn't exist
in Termux, so the command crashes silently. The `--quiet` flag disables that lookup
entirely, making auth work reliably on Android.

---

## After Installation

Once setup is complete, use this single command to SSH into your Google Cloud Shell:

```bash
gcs
```

To switch projects:

```bash
gcloud config set project YOUR_PROJECT_ID
```

To list your projects:

```bash
gcloud projects list
```

---

## Requirements

- Android device running [Termux](https://termux.dev)
- ARM64 architecture (most modern Android phones)
- Active Google account

---

## Manual Installation

If you prefer to run steps yourself:

```bash
# 1. Install dependencies
pkg update -y && pkg install python curl binutils tar -y

# 2. Download and install SDK
curl -O https://sdk.cloud.google.com
bash sdk.cloud.google.com --install-dir=$HOME --no-standard-compliance --disable-prompts

# 3. Add to PATH
echo 'export PATH="$PATH:$HOME/google-cloud-sdk/bin"' >> ~/.bashrc
source ~/.bashrc

# 4. Authenticate (the working command for Termux)
gcloud auth login --no-launch-browser --quiet
```

---

## License

MIT — free to use, modify, and share.
