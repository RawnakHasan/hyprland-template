#!/usr/bin/env bash

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_FILE="$SCRIPT_DIR/pkg.txt"

if [[ ! -f "$PACKAGE_FILE" ]]; then
    echo "Error: $PACKAGE_FILE not found!"
    exit 1
fi

# Detect distro
if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    DISTRO=$ID
else
    echo "Cannot detect distribution."
    exit 1
fi

# Read packages into array (ignore empty lines and comments)
mapfile -t PACKAGES < <(grep -vE '^\s*#|^\s*$' "$PACKAGE_FILE")

if [[ ${#PACKAGES[@]} -eq 0 ]]; then
    echo "No packages found in $PACKAGE_FILE"
    exit 1
fi

echo "Detected distro: $DISTRO"
echo "Installing packages: ${PACKAGES[*]}"

install_arch() {
    sudo pacman -Syu --needed --noconfirm "${PACKAGES[@]}"
}

install_debian() {
    sudo apt update
    sudo apt install -y "${PACKAGES[@]}"
}

install_fedora() {
    sudo dnf upgrade --refresh -y
    sudo dnf install -y "${PACKAGES[@]}"
}

case "$DISTRO" in
    arch|manjaro|endeavouros)
        install_arch
        ;;
    debian|ubuntu|linuxmint)
        install_debian
        ;;
    fedora)
        install_fedora
        ;;
    *)
        echo "Unsupported distribution: $DISTRO"
        exit 1
        ;;
esac

echo "Installation complete!"
