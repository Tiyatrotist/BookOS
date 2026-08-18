#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

usage() {
  cat <<'EOF'
BookOS build entry point

Usage:
  sudo ./scripts/build.sh bootstrap-rootfs
  sudo ./scripts/build.sh clean
  ./scripts/build.sh info
EOF
}

case "${1:-}" in
  bootstrap-rootfs)
    exec "$ROOT_DIR/scripts/bootstrap-rootfs.sh"
    ;;
  clean)
    rm -rf "$ROOT_DIR/build/rootfs" "$ROOT_DIR/build/out"
    echo "BookOS build output cleaned."
    ;;
  info)
    # shellcheck disable=SC1091
    source "$ROOT_DIR/config/bookos.conf"
    printf 'Name: %s\nRelease: %s\nArchitecture: %s\n' \
      "$BOOKOS_NAME" "$BOOKOS_RELEASE" "$BOOKOS_ARCH"
    ;;
  *)
    usage
    exit 1
    ;;
esac
