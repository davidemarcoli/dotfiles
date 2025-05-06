# System Files

This directory contains system files that need root permissions to install.

## Structure

- `NetworkManager/dispatcher.d/` - NetworkManager dispatcher scripts
  - `99-wireguard-auto-disconnect` - Auto-disconnects WireGuard on home network

## Installation

These files are automatically installed when running `chezmoi apply` via the 
`run_onchange_install-system-files.sh` script.

## Adding New System Files

1. Create the file in the appropriate subdirectory
2. The installation script will automatically pick it up
3. Add documentation here

## Configuration

Some files use templating. Configure values in `~/.config/chezmoi/chezmoi.toml`:

```toml
[data]
homeSSID = "YOUR_HOME_NETWORK_SSID"

[data.zhaw] 
identity = "MyFancyIdentity",
password = "YourSecurePassword"  # Replace with your actual password
```