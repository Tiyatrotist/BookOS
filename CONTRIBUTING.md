# Contributing to BookOS

BookOS is currently in early development. The project is being designed around a reproducible Debian ARM64 base, KDE Plasma/Wayland, and the Fusion tablet experience.

## Development principles

1. Keep hardware-specific code under `device/` whenever possible.
2. Keep branding and visual assets under `branding/`.
3. Do not commit generated build output or local credentials.
4. Prefer reproducible build scripts over undocumented manual steps.
5. Test changes on the intended hardware or clearly document when hardware testing was not possible.
6. Preserve upstream licenses and attribution for third-party components.

## Commit style

Use concise, descriptive commit messages, for example:

```text
build: add initial Debian ARM64 bootstrap
ui: add Fusion tablet layout
hw: add yunluo device configuration
branding: add BookOS icon set
```
