#!/bin/bash
# uninstall.sh - Zin uninstallation script
# Usage: curl -fsSL https://unvt.github.io/zin/uninstall.sh | sudo -E bash -

set -e

echo "=========================================="
echo "Zin - Uninstallation"
echo "=========================================="
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo "Error: This script must be run as root (use sudo)"
  exit 1
fi

echo "Step 1: Stopping and disabling Caddy service..."
if systemctl is-active --quiet caddy; then
  systemctl stop caddy
  echo "✓ Caddy stopped"
fi

if systemctl is-enabled --quiet caddy 2>/dev/null; then
  systemctl disable caddy
  echo "✓ Caddy disabled"
fi

echo ""
echo "Step 2: Removing Caddy package..."
apt-get remove -y caddy
apt-get autoremove -y

echo ""
echo "Step 3: Removing Caddy repository configuration..."
rm -f /etc/apt/sources.list.d/caddy-stable.list
rm -f /usr/share/keyrings/caddy-stable-archive-keyring.gpg

echo ""
echo "Step 4: Cleaning up configuration files..."
rm -rf /etc/caddy
rm -rf /var/log/caddy

echo ""
# Determine whether to remove the zin user and data directory.
# If ZIN_REMOVE_USER is set, use it as the answer (non-interactive mode).
# Otherwise, prompt only when stdin is a TTY; default to "no" when non-interactive.
if [ -n "${ZIN_REMOVE_USER:-}" ]; then
  REPLY="$ZIN_REMOVE_USER"
else
  if [ -t 0 ]; then
    read -p "Remove zin user and data directory /home/zin? (y/N) " -n 1 -r
    echo
  else
    echo "Non-interactive input detected; keeping zin user and data directory by default."
    REPLY="n"
  fi
fi
if [[ "$REPLY" =~ ^[Yy]$ ]]; then
  echo "Removing zin user and home directory..."
  if id -u zin > /dev/null 2>&1; then
    if pgrep -u zin > /dev/null 2>&1; then
      echo "Warning: Cannot remove 'zin' user because there are processes still running as that user."
      echo "Please stop these processes and run this uninstallation again, or remove the user manually:"
      echo "  sudo userdel -r zin"
    else
      if ! userdel -r zin 2>/dev/null; then
        echo "Warning: Failed to remove 'zin' user and home directory."
        echo "You may need to manually run: sudo userdel -r zin"
      else
        echo "✓ zin user removed"
      fi
    fi
  fi
else
  echo "Keeping zin user and data directory"
  echo "To manually remove later: sudo userdel -r zin"
fi

echo ""
echo "=========================================="
echo "Uninstallation complete!"
echo "=========================================="
echo ""
echo "To reinstall:"
echo "  curl -fsSL https://unvt.github.io/zin/install.sh | sudo -E bash -"
echo ""
