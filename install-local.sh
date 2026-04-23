#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ID="K-Splash"
DEFAULT_ARCHIVE="$SCRIPT_DIR/${PLUGIN_ID}.plasmoid"
ARCHIVE_PATH="${1:-$DEFAULT_ARCHIVE}"
XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
PLASMOID_ROOT="$XDG_DATA_HOME/plasma/plasmoids"
TARGET_DIR="$PLASMOID_ROOT/$PLUGIN_ID"
TMP_DIR="$(mktemp -d)"
RESTORE_LOCAL_CONFIG=0
LOCAL_CONFIG_BACKUP="$TMP_DIR/local.json.backup"
APT_RUNTIME_PACKAGE_GROUPS=(
    "unzip"
    "curl"
    "qdbus-qt6 qdbus-qt5 qt6-tools-dev-tools qttools5-dev-tools"
    "libcanberra-gtk3-module libcanberra-gtk-module"
    "libcanberra0 libcanberra-gtk3-0"
)

cleanup() {
    rm -rf "$TMP_DIR"
}

trap cleanup EXIT

install_apt_runtime_packages() {
    local missing_packages=()
    local group
    local selected_package

    for group in "${APT_RUNTIME_PACKAGE_GROUPS[@]}"; do
        selected_package="$(select_apt_package $group)"

        if [[ -z "$selected_package" ]]; then
            echo "Warning: no installable apt package found for: $group" >&2
            continue
        fi

        if ! dpkg -s "$selected_package" >/dev/null 2>&1; then
            missing_packages+=("$selected_package")
        fi
    done

    if [[ "${#missing_packages[@]}" -eq 0 ]]; then
        return
    fi

    echo "Installing runtime packages with apt: ${missing_packages[*]}"

    if [[ "$EUID" -eq 0 ]]; then
        apt-get update
        apt-get install -y "${missing_packages[@]}"
        return
    fi

    if command -v sudo >/dev/null 2>&1; then
        sudo apt-get update
        sudo apt-get install -y "${missing_packages[@]}"
        return
    fi

    echo "Missing apt packages: ${missing_packages[*]}" >&2
    echo "Re-run as root or install them manually before installing $PLUGIN_ID." >&2
    exit 1
}

apt_package_exists() {
    local package="$1"
    apt-cache show "$package" >/dev/null 2>&1
}

select_apt_package() {
    local package

    for package in "$@"; do
        if dpkg -s "$package" >/dev/null 2>&1; then
            printf '%s\n' "$package"
            return 0
        fi

        if apt_package_exists "$package"; then
            printf '%s\n' "$package"
            return 0
        fi
    done

    return 1
}

if [[ ! -f "$ARCHIVE_PATH" ]]; then
    echo "Archive not found: $ARCHIVE_PATH" >&2
    echo "Usage: $0 [/path/to/${PLUGIN_ID}.plasmoid]" >&2
    exit 1
fi

if command -v apt-get >/dev/null 2>&1; then
    install_apt_runtime_packages
fi

if ! command -v unzip >/dev/null 2>&1; then
    echo "'unzip' is required to install $PLUGIN_ID" >&2
    exit 1
fi

mkdir -p "$PLASMOID_ROOT"

if [[ -f "$TARGET_DIR/contents/config/local.json" ]]; then
    cp "$TARGET_DIR/contents/config/local.json" "$LOCAL_CONFIG_BACKUP"
    RESTORE_LOCAL_CONFIG=1
fi

unzip -q "$ARCHIVE_PATH" -d "$TMP_DIR/unpacked"

if [[ ! -f "$TMP_DIR/unpacked/metadata.json" || ! -d "$TMP_DIR/unpacked/contents" ]]; then
    echo "Archive does not look like a Plasma plasmoid package: $ARCHIVE_PATH" >&2
    exit 1
fi

rm -rf "$TARGET_DIR"
mkdir -p "$TARGET_DIR"
cp -a "$TMP_DIR/unpacked/." "$TARGET_DIR/"

if [[ "$RESTORE_LOCAL_CONFIG" -eq 1 ]]; then
    mkdir -p "$TARGET_DIR/contents/config"
    cp "$LOCAL_CONFIG_BACKUP" "$TARGET_DIR/contents/config/local.json"
fi

echo "Installed $PLUGIN_ID to $TARGET_DIR"
echo "Restart plasmashell to reload the updated widget:"
echo "  kquitapp6 plasmashell && kstart plasmashell"
