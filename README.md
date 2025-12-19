# zin

Minimal PMTiles tile server for Raspberry Pi Zero W

## Overview

Zin is a streamlined version of [unvt/niroku](https://github.com/unvt/niroku), designed specifically for serving PMTiles on Raspberry Pi Zero W (armv6l) with Raspberry Pi OS Lite. It uses Caddy web server to deliver PMTiles files efficiently via HTTP Range requests.

### Features

- **Lightweight**: Minimal setup designed for Raspberry Pi Zero W
- **Simple**: Single-command installation via pipe-to-shell
- **PMTiles Support**: Native HTTP Range request support for efficient tile serving
- **Utilities**: Includes useful tools like ncdu, htop, and tree
- **Easy Management**: Simple systemd service management

## Quick Start

### Installation

Install zin on your Raspberry Pi Zero W with a single command:

```bash
curl -fsSL https://unvt.github.io/zin/install.sh | sudo -E bash -
```

Or if you prefer wget:

```bash
wget -qO- https://unvt.github.io/zin/install.sh | sudo -E bash -
```

### What Gets Installed

- **Caddy web server**: Modern web server with automatic HTTPS
- **System utilities**: ncdu, htop, tree
- **User and directories**: `zin` user with `/home/zin/zin` as document root
- **Service**: Caddy configured as systemd service at `zin.local`

### Usage

1. **Add PMTiles files** to the document root:
   ```bash
   sudo cp your-map.pmtiles /home/zin/zin/
   sudo chown zin:zin /home/zin/zin/your-map.pmtiles
   ```

2. **Access your tiles** via HTTP:
   ```
   http://zin.local/your-map.pmtiles
   ```

3. **Browse files** in your browser:
   ```
   http://zin.local
   ```

### Uninstallation

Remove zin from your system:

```bash
curl -fsSL https://unvt.github.io/zin/uninstall.sh | sudo -E bash -
```

## System Requirements

- Raspberry Pi Zero W (armv6l) or compatible device
- Raspberry Pi OS Lite (or other Debian-based distribution)
- Internet connection for installation
- Hostname configured as `zin.local` (or modify Caddyfile)

## Management

### Service Control

```bash
# Check status
sudo systemctl status caddy

# Restart service
sudo systemctl restart caddy

# View logs
sudo journalctl -u caddy -f

# View access logs
sudo tail -f /var/log/caddy/zin.log
```

### Disk Usage

Check disk space usage of your PMTiles:

```bash
ncdu /home/zin/zin
```

## Architecture

Zin uses a simple architecture:

```
┌─────────────────────────────────────┐
│     Client (Browser/Map App)        │
└──────────────┬──────────────────────┘
               │ HTTP Range Requests
┌──────────────▼──────────────────────┐
│        Caddy Web Server             │
│        (zin.local)                  │
└──────────────┬──────────────────────┘
               │ File System
┌──────────────▼──────────────────────┐
│    /home/zin/zin/*.pmtiles          │
└─────────────────────────────────────┘
```

### Why Caddy?

- Native HTTP Range request support for PMTiles
- Automatic HTTPS (if domain is configured)
- Built-in file server with directory browsing
- Simple configuration
- Low resource usage (perfect for Pi Zero W)

## Configuration

### Caddyfile

The Caddy configuration is located at `/etc/caddy/Caddyfile`:

```caddy
zin.local {
    root * /home/zin/zin
    file_server browse
    
    header {
        Access-Control-Allow-Origin *
        Access-Control-Allow-Methods "GET, OPTIONS"
        Access-Control-Allow-Headers "Range"
    }
    
    encode gzip
    
    log {
        output file /var/log/caddy/zin.log
        format json
    }
}
```

To modify the configuration:

1. Edit `/etc/caddy/Caddyfile`
2. Test configuration: `sudo caddy validate --config /etc/caddy/Caddyfile`
3. Reload: `sudo systemctl reload caddy`

## PMTiles

PMTiles is a single-file archive format for tiled map data, optimized for cloud storage and efficient serving via HTTP Range requests.

### Creating PMTiles

Use tools like:
- [tippecanoe](https://github.com/felt/tippecanoe)
- [go-pmtiles](https://github.com/protomaps/go-pmtiles)
- [GDAL](https://gdal.org/)

Example with tippecanoe:
```bash
tippecanoe -o output.pmtiles input.geojson
```

### Using PMTiles in Web Maps

PMTiles can be used with various mapping libraries:

- MapLibre GL JS
- Leaflet (with plugin)
- OpenLayers

See [PMTiles documentation](https://docs.protomaps.com/pmtiles/) for details.

## Troubleshooting

### Service not starting

Check logs:
```bash
sudo journalctl -u caddy -n 50
```

### Cannot access zin.local

1. Check if Caddy is running: `sudo systemctl status caddy`
2. Verify hostname resolution: `ping zin.local`
3. Check firewall settings
4. Try accessing via IP address

### Permission issues

Ensure files are owned by zin user:
```bash
sudo chown -R zin:zin /home/zin/zin
sudo chmod -R 755 /home/zin/zin
```

## Development

### Manual Installation

For development or inspection:

```bash
# Download scripts
curl -fsSL https://unvt.github.io/zin/install.sh -o install.sh
curl -fsSL https://unvt.github.io/zin/uninstall.sh -o uninstall.sh
curl -fsSL https://unvt.github.io/zin/Caddyfile -o Caddyfile

# Review and execute
chmod +x install.sh
sudo ./install.sh
```

## Related Projects

- [unvt/niroku](https://github.com/unvt/niroku) - Full-featured UNVT Portable with Martin tile server
- [United Nations Vector Tile Toolkit](https://github.com/unvt)
- [PMTiles](https://github.com/protomaps/PMTiles)
- [Caddy](https://caddyserver.com/)

## License

CC0 1.0 Universal

## Contributing

Issues and pull requests are welcome on [GitHub](https://github.com/unvt/zin).
