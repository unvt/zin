#!/bin/bash
# install.sh - Zin installation script for Raspberry Pi Zero W
# Minimal PMTiles tile server using Caddy
# Usage: curl -fsSL https://unvt.github.io/zin/install.sh | sudo -E bash -

set -e

echo "=========================================="
echo "Zin - Minimal PMTiles Tile Server"
echo "Installation for Raspberry Pi Zero W"
echo "=========================================="
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo "Error: This script must be run as root (use sudo)"
  exit 1
fi

# Check architecture
ARCH=$(uname -m)
echo "Detected architecture: $ARCH"
if [ "$ARCH" != "armv6l" ] && [ "$ARCH" != "armv7l" ] && [ "$ARCH" != "aarch64" ]; then
  echo "Warning: This script is designed for Raspberry Pi (armv6l/armv7l/aarch64)"
  echo "Current architecture: $ARCH"
  read -p "Continue anyway? (y/N) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
  fi
fi

echo ""
echo "Step 1: Installing system utilities..."
apt-get update
apt-get install -y curl wget ca-certificates ncdu htop tree

echo ""
echo "Step 2: Installing Caddy web server..."
# Following https://caddyserver.com/docs/install#debian-ubuntu-raspbian
apt-get install -y debian-keyring debian-archive-keyring apt-transport-https
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | tee /etc/apt/sources.list.d/caddy-stable.list
apt-get update
apt-get install -y caddy

echo ""
echo "Step 3: Creating zin user and directory structure..."
# Create zin user if it doesn't exist
if ! id -u zin > /dev/null 2>&1; then
  useradd -r -m -d /home/zin -s /bin/bash zin
  echo "Created zin user"
else
  echo "zin user already exists"
fi

# Create zin directory for PMTiles files
mkdir -p /home/zin/zin
chown -R zin:zin /home/zin/zin
chmod 755 /home/zin/zin

echo ""
echo "Step 4: Downloading and installing Caddyfile..."
# Download Caddyfile from GitHub Pages
if ! curl -fsSL https://unvt.github.io/zin/Caddyfile -o /etc/caddy/Caddyfile; then
  echo "Error: Failed to download Caddyfile"
  echo "You may need to create /etc/caddy/Caddyfile manually"
  exit 1
fi
chmod 644 /etc/caddy/Caddyfile

# Create log directory
mkdir -p /var/log/caddy
chown caddy:caddy /var/log/caddy

echo ""
echo "Step 5: Configuring and starting Caddy service..."
# Enable and start Caddy
systemctl enable caddy
systemctl restart caddy

echo ""
echo "Step 6: Verifying installation..."
sleep 2
if systemctl is-active --quiet caddy; then
  echo "✓ Caddy is running"
else
  echo "✗ Caddy failed to start"
  echo "Check logs with: sudo journalctl -u caddy -n 50"
  exit 1
fi

echo ""
echo "=========================================="
echo "Installation complete!"
echo "=========================================="
echo ""
echo "Document root: /home/zin/zin"
echo "Server: http://zin.local"
echo ""
echo "Next steps:"
echo "1. Add PMTiles files to /home/zin/zin/"
echo "2. Access the server at http://zin.local"
echo ""
echo "Useful commands:"
echo "  sudo systemctl status caddy    # Check Caddy status"
echo "  sudo systemctl restart caddy   # Restart Caddy"
echo "  sudo journalctl -u caddy -f    # View Caddy logs"
echo "  ncdu /home/zin/zin             # Check disk usage"
echo ""
echo "To uninstall:"
echo "  curl -fsSL https://unvt.github.io/zin/uninstall.sh | sudo -E bash -"
echo ""
