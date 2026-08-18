#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$ROOT_DIR/config/bookos.conf"

if [[ "$(id -u)" -ne 0 ]]; then
  echo "Run this script with sudo: sudo $0"
  exit 1
fi

command -v debootstrap >/dev/null 2>&1 || {
  echo "debootstrap is required. Install it with: sudo apt install debootstrap"
  exit 1
}

mkdir -p "$ROOT_DIR/build"
rm -rf "$BOOKOS_ROOTFS"

# Stage 1: create a minimal Debian ARM64 filesystem.
debootstrap \
  --arch="$BOOKOS_ARCH" \
  --variant=minbase \
  "$BOOKOS_RELEASE" \
  "$BOOKOS_ROOTFS" \
  "$BOOKOS_MIRROR"

echo "BookOS ARM64 rootfs created at: $BOOKOS_ROOTFS"
