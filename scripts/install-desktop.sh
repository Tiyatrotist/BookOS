#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$ROOT_DIR/config/bookos.conf"

if [[ "$(id -u)" -ne 0 ]]; then
  echo "Run this script with sudo: sudo $0"
  exit 1
fi

ROOTFS_DIR="$BOOKOS_ROOTFS"
if [[ "$ROOTFS_DIR" != /* ]]; then
  ROOTFS_DIR="$ROOT_DIR/$ROOTFS_DIR"
fi

MANIFEST="$ROOT_DIR/config/desktop-packages.list"

if [[ ! -x "$ROOTFS_DIR/bin/bash" ]]; then
  echo "ARM64 rootfs not found or incomplete: $ROOTFS_DIR"
  echo "Run: sudo ./scripts/build.sh bootstrap-rootfs"
  exit 1
fi

if [[ ! -f "$MANIFEST" ]]; then
  echo "Desktop package manifest not found: $MANIFEST"
  exit 1
fi

TARGET_ARCH="$(chroot "$ROOTFS_DIR" dpkg --print-architecture)"
if [[ "$TARGET_ARCH" != "$BOOKOS_ARCH" ]]; then
  echo "Rootfs architecture mismatch: expected $BOOKOS_ARCH, got $TARGET_ARCH"
  exit 1
fi

HOST_ARCH="$(dpkg --print-architecture 2>/dev/null || true)"
QEMU_AARCH64="/usr/bin/qemu-aarch64-static"
CROSS_BOOTSTRAP=false
if [[ "$BOOKOS_ARCH" != "$HOST_ARCH" ]]; then
  CROSS_BOOTSTRAP=true
fi

if [[ "$CROSS_BOOTSTRAP" == true && "$BOOKOS_ARCH" == "arm64" ]]; then
  if [[ ! -x "$QEMU_AARCH64" ]]; then
    echo "qemu-aarch64-static is required for ARM64 desktop installation."
    echo "Install it with: sudo apt install qemu-user-static"
    exit 1
  fi
  install -D -m 0755 "$QEMU_AARCH64" "$ROOTFS_DIR/usr/bin/qemu-aarch64-static"
fi

RESOLV_FILE="$ROOTFS_DIR/etc/resolv.conf"
RESOLV_BACKUP=""
RESOLV_HAD_FILE=false
if [[ -e "$RESOLV_FILE" || -L "$RESOLV_FILE" ]]; then
  RESOLV_HAD_FILE=true
  RESOLV_BACKUP="$(mktemp)"
  cp -a "$RESOLV_FILE" "$RESOLV_BACKUP"
fi

POLICY_FILE="$ROOTFS_DIR/usr/sbin/policy-rc.d"
POLICY_BACKUP=""
POLICY_HAD_FILE=false
if [[ -e "$POLICY_FILE" || -L "$POLICY_FILE" ]]; then
  POLICY_HAD_FILE=true
  POLICY_BACKUP="$(mktemp)"
  cp -a "$POLICY_FILE" "$POLICY_BACKUP"
fi

cleanup() {
  rm -f "$ROOTFS_DIR/tmp/bookos-desktop-packages.list"

  if [[ "$POLICY_HAD_FILE" == true ]]; then
    rm -f "$POLICY_FILE"
    cp -a "$POLICY_BACKUP" "$POLICY_FILE"
    rm -f "$POLICY_BACKUP"
  else
    rm -f "$POLICY_FILE"
  fi

  if [[ "$RESOLV_HAD_FILE" == true ]]; then
    rm -f "$RESOLV_FILE"
    cp -a "$RESOLV_BACKUP" "$RESOLV_FILE"
    rm -f "$RESOLV_BACKUP"
  else
    rm -f "$RESOLV_FILE"
  fi

  if [[ "$CROSS_BOOTSTRAP" == true && "$BOOKOS_ARCH" == "arm64" ]]; then
    rm -f "$ROOTFS_DIR/usr/bin/qemu-aarch64-static"
  fi
}
trap cleanup EXIT

mkdir -p "$ROOTFS_DIR/tmp"

rm -f "$RESOLV_FILE"
cp -L /etc/resolv.conf "$RESOLV_FILE"

cat > "$POLICY_FILE" <<'EOF'
#!/bin/sh
exit 101
EOF
chmod 0755 "$POLICY_FILE"

awk '!/^[[:space:]]*#/ && NF {print}' "$MANIFEST" > "$ROOTFS_DIR/tmp/bookos-desktop-packages.list"

PACKAGE_COUNT="$(wc -l < "$ROOTFS_DIR/tmp/bookos-desktop-packages.list")"
echo "==> Installing $PACKAGE_COUNT BookOS desktop packages"

chroot "$ROOTFS_DIR" /bin/bash -c '
  set -euo pipefail
  export DEBIAN_FRONTEND=noninteractive
  export LC_ALL=C
  apt-get update
  xargs -r apt-get install -y --no-install-recommends < /tmp/bookos-desktop-packages.list
  apt-get clean
  rm -rf /var/lib/apt/lists/*
'

# Enable the graphical login manager without attempting to start it in the build chroot.
systemctl --root="$ROOTFS_DIR" enable sddm.service
target="$ROOTFS_DIR/etc/systemd/system/default.target"
ln -sfn /lib/systemd/system/graphical.target "$target"

echo "BookOS KDE Plasma Wayland desktop installation completed."
echo "Display manager: $(readlink -f "$ROOTFS_DIR/etc/systemd/system/display-manager.service")"
