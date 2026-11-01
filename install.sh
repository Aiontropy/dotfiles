#!/usr/bin/env bash
#
# Dotfiles installation script
#
# Usage:
#   ./install.sh                 # Link all configurations
#   ./install.sh nvim niri       # Link specific configurations
#   ./install.sh --dry-run       # Preview changes without applying them
#   ./install.sh --unlink        # Remove symbolic links
#

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ============ Configuration Mapping ============
declare -A LINK_MAP=(
    ["nvim"]="$HOME/.config/nvim"
    ["mihomo"]="/etc/mihomo"
    ["niri"]="$HOME/.config/niri"
    ["vibepanel"]="$HOME/.config/vibepanel"
)
# ================================================

DRY_RUN=0
UNLINK=0
ONLY=()

for arg in "$@"; do
    case "$arg" in
        --dry-run|-n) DRY_RUN=1 ;;
        --unlink)     UNLINK=1 ;;
        --help|-h)
            grep '^#' "$0" | head -12
            exit 0
            ;;
        *) ONLY+=("$arg") ;;
    esac
done

# Execute a command
run() {
    if [[ "$DRY_RUN" -eq 1 ]]; then
        echo "[dry-run] $*"
    else
        "$@"
    fi
}

# Execute a command with elevated privileges
run_privileged() {
    if [[ "$DRY_RUN" -eq 1 ]]; then
        echo "[dry-run] sudo $*"
    else
        sudo "$@"
    fi
}

# Check whether a target requires elevated privileges
needs_sudo() {
    [[ "$1" == /etc/* ]]
}

# Create a symbolic link
link_one() {
    local src="$1"
    local dst="$2"
    local backup

    # Skip if the correct symbolic link already exists
    if [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]]; then
        echo "Skipped (already linked): $dst"
        return
    fi

    # Back up existing files or directories
    if [[ -e "$dst" || -L "$dst" ]]; then
        backup="${dst}.bak.$(date +%Y%m%d%H%M%S)"
        echo "Backup: $dst -> $backup"

        if needs_sudo "$dst"; then
            run_privileged mv "$dst" "$backup"
        else
            run mv "$dst" "$backup"
        fi
    fi

    echo "Linking: $src -> $dst"

    if needs_sudo "$dst"; then
        run_privileged mkdir -p "$(dirname "$dst")"
        run_privileged ln -s "$src" "$dst"
    else
        run mkdir -p "$(dirname "$dst")"
        run ln -s "$src" "$dst"
    fi
}

# Remove a symbolic link
unlink_one() {
    local dst="$1"

    if [[ -L "$dst" ]]; then
        echo "Removing link: $dst"

        if needs_sudo "$dst"; then
            run_privileged rm "$dst"
        else
            run rm "$dst"
        fi
    fi
}

# Check whether a file should be excluded
should_skip() {
    local rel="$1"

    case "$rel" in
        # Git metadata
        .git|.git/*|*/.git|*/.git/*)
            return 0
            ;;
        .github|.github/*|*/.github|*/.github/*)
            return 0
            ;;
        .gitignore|*/.gitignore|.gitattributes|*/.gitattributes)
            return 0
            ;;

        # Documentation and runtime databases
        README*|*.md|*.db|*.sqlite|*.sqlite3)
            return 0
            ;;

        # Temporary and backup files
        *.bak|*.tmp|*.log)
            return 0
            ;;
    esac

    return 1
}

# Main
for dir in "${!LINK_MAP[@]}"; do

    # Process only explicitly specified configurations
    if [[ ${#ONLY[@]} -gt 0 ]]; then
        skip=1

        for o in "${ONLY[@]}"; do
            [[ "$o" == "$dir" ]] && skip=0
        done

        [[ "$skip" -eq 1 ]] && continue
    fi

    src_root="$DOTFILES_DIR/$dir"
    dst_root="${LINK_MAP[$dir]}"

    if [[ ! -d "$src_root" ]]; then
        echo "Warning: Source directory does not exist, skipping: $src_root" >&2
        continue
    fi

    echo
    echo "Processing: $dir"
    echo "Source: $src_root"
    echo "Target: $dst_root"

    while IFS= read -r -d '' src; do
        rel="${src#"$src_root"/}"

        if should_skip "$rel"; then
            echo "Skipped (excluded): $rel"
            continue
        fi

        dst="$dst_root/$rel"

        if [[ "$UNLINK" -eq 1 ]]; then
            unlink_one "$dst"
        else
            link_one "$src" "$dst"
        fi

    done < <(
        find "$src_root" \
            -type d \( -name .git -o -name .github \) -prune -o \
            -type f -print0
    )
done

echo
echo "Done."
