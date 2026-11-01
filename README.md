# Dotfiles

Personal Linux configuration files managed with Git and symbolic links.

## Overview

This repository contains configuration files for my Linux desktop environment and applications.

The installation script automatically creates symbolic links from this repository to their corresponding configuration directories.

## Repository Structure

```text
dotfiles/
├── install.sh
├── mihomo/
│   ├── config.yaml
│   ├── country.mmdb
│   └── geoip.metadb
├── niri/
│   └── config.kdl
├── nvim/
│   ├── init.lua
│   └── lua/
└── vibepanel/
```

## Managed Configurations

| Directory | Target | Description |
|---|---|---|
| `nvim/` | `~/.config/nvim/` | Neovim configuration |
| `niri/` | `~/.config/niri/` | Niri window manager |
| `mihomo/` | `/etc/mihomo/` | Mihomo proxy configuration |
| `vibepanel/` | `~/.config/vibepanel/` | VibePanel configuration |

## Installation

Clone the repository:

```bash
git clone https://github.com/Aiontropy/dotfiles ~/Projects/dotfiles
cd ~/Projects/dotfiles
```

Make the installation script executable:

```bash
chmod +x install.sh
```

Run a dry run first to preview the changes:

```bash
./install.sh --dry-run
```

Install all configurations:

```bash
./install.sh
```

The script automatically requests `sudo` when managing files under `/etc/`.

## Usage

### Install all configurations

```bash
./install.sh
```

### Install specific configurations

```bash
./install.sh nvim
./install.sh niri
./install.sh mihomo
```

Multiple configurations can be specified:

```bash
./install.sh nvim niri
```

### Dry run

Preview operations without modifying files:

```bash
./install.sh --dry-run
```

### Remove symbolic links

```bash
./install.sh --unlink
```

This removes symbolic links created at the target locations. It does not restore backup files.

## How It Works

The installation script uses symbolic links (`ln -s`) to connect repository files to their target locations.

For example:

```text
~/Projects/dotfiles/nvim/init.lua
                |
                v
~/.config/nvim/init.lua
```

Changes made to files in this repository are immediately reflected in the corresponding configuration locations.

Existing files are backed up before being replaced:

```text
config.yaml
config.yaml.bak.TIMESTAMP
```

Already-correct symbolic links are automatically skipped.

## Excluded Files

The installation script ignores files and directories that should not be linked.

| Pattern | Reason |
|---|---|
| `.git/` | Git repository metadata |
| `.github/` | GitHub repository configuration |
| `.gitignore` | Git ignore rules |
| `.gitattributes` | Git attributes |
| `README*` | Documentation |
| `*.md` | Markdown documentation |
| `*.db` | Runtime databases |
| `*.sqlite` | SQLite databases |
| `*.sqlite3` | SQLite databases |
| `*.bak` | Backup files |
| `*.tmp` | Temporary files |
| `*.log` | Log files |

These files remain in the repository but are not linked to configuration directories.

## Notes

- Do not run the entire installation script with `sudo`.
- User configuration files are managed as the current user.
- System configuration files under `/etc/` require elevated privileges.
- Runtime databases and temporary files should not be committed to Git.
- Backups are retained with a timestamp suffix.

## License

Personal use. Feel free to adapt the configurations to your own environment.
