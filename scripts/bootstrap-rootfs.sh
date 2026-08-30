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

ROOTFS_DIR="$BOOKOS_ROOTFS"
if [[ "$ROOTFS_DIR" != /* ]]; then
  ROOTFS_DIR="$ROOT_DIR/$ROOTFS_DIR"
fi

HOST_ARCH="$(dpkg --print-architecture 2>/dev/null || true)"
CROSS_BOOTSTRAP=false

if [[ "$BOOKOS_ARCH" != "$HOST_ARCH" ]]; then
  CROSS_BOOTSTRAP=true
fi

QEMU_AARCH64="/usr/bin/qemu-aarch64-static"
if [[ "$CROSS_BOOTSTRAP" == true && "$BOOKOS_ARCH" == "arm64" ]]; then
  if [[ ! -x "$QEMU_AARCH64" ]]; then
    echo "qemu-aarch64-static is required for ARM64 cross-bootstrap."
    echo "Install it with: sudo apt install qemu-user-static"
    exit 1
  fi
fi

mkdir -p "$ROOT_DIR/build"
rm -rf "$ROOTFS_DIR"

if [[ "$CROSS_BOOTSTRAP" == true ]]; then
  echo "==> Stage 1: bootstrapping Debian $BOOKOS_RELEASE ($BOOKOS_ARCH) on $HOST_ARCH"
  debootstrap \
    --foreign \
    --arch="$BOOKOS_ARCH" \
    --variant=minbase \
    "$BOOKOS_RELEASE" \
    "$ROOTFS_DIR" \
    "$BOOKOS_MIRROR"

  if [[ "$BOOKOS_ARCH" == "arm64" ]]; then
    install -D -m 0755 "$QEMU_AARCH64" "$ROOTFS_DIR/usr/bin/qemu-aarch64-static"

    if [[ -x /usr/sbin/update-binfmts ]]; then
      /usr/sbin/update-binfmts --enable qemu-aarch64 >/dev/null 2>&1 || true
    fi

    BINFMT_HANDLER="/proc/sys/fs/binfmt_misc/qemu-aarch64"
    if [[ ! -e "$BINFMT_HANDLER" ]]; then
      echo "ARM64 binfmt_misc support is not enabled on this host."
      echo "Install it with: sudo apt install qemu-user-binfmt binfmt-support"
      echo "Then rerun: sudo ./scripts/build.sh bootstrap-rootfs"
      exit 1
    fi

    chroot "$ROOTFS_DIR" /bin/true
  fi

  echo "==> Stage 2: finalizing $BOOKOS_ARCH base system"
  chroot "$ROOTFS_DIR" /debootstrap/debootstrap --second-stage
else
  echo "==> Native bootstrap: Debian $BOOKOS_RELEASE ($BOOKOS_ARCH)"
  debootstrap \
    --arch="$BOOKOS_ARCH" \
    --variant=minbase \
    "$BOOKOS_RELEASE" \
    "$ROOTFS_DIR" \
    "$BOOKOS_MIRROR"
fi

# Install the versioned BookOS base package set. The installer keeps QEMU
# available in ARM64 rootfs builds until all package post-install scripts finish.
echo "==> Installing BookOS base package set"
bash "$ROOT_DIR/scripts/install-rootfs-packages.sh"

echo "BookOS $BOOKOS_ARCH rootfs created at: $ROOTFS_DIR"
echo "Architecture: $(chroot "$ROOTFS_DIR" dpkg --print-architecture)"
