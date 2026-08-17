# BookOS

> **Linux. Reimagined for Touch.**

BookOS is a tablet-first Linux distribution project built around Debian ARM64, KDE Plasma, Wayland, and a custom **Fusion** user experience.

The initial hardware target is the Xiaomi Redmi Pad (`yunluo`, MT6789/MT8781V / Helio G99), while the project architecture is intended to support additional tablet hardware in the future.

## Vision

BookOS aims to combine:

- A full Linux desktop environment
- A touch-first tablet experience
- A fast, customizable KDE/Wayland foundation
- Automatic tablet/desktop workflow adaptation
- BookOS branding, icons, themes, and system UI
- Optional Android application support through Waydroid

## Fusion UX

Fusion is the primary BookOS design direction:

- **Tablet Mode:** BookOS-first touch interface with large controls and gestures
- **Desktop Mode:** traditional KDE Plasma workflow for keyboard and mouse
- **Shared foundation:** both modes run on the same Linux/Wayland system

## Project Status

🚧 **Early development — architecture and build system stage.**

No BookOS image is currently considered production-ready.

## Target Stack

| Layer | Initial target |
|---|---|
| Base | Debian ARM64 |
| Desktop | KDE Plasma |
| Display stack | Wayland |
| Tablet shell | BookOS Fusion |
| Android compatibility | Waydroid (later) |
| Initial device | Xiaomi Redmi Pad / `yunluo` |
| Architecture | ARM64 |

## Repository Layout

```text
BookOS/
├── apps/          # BookOS applications
├── branding/      # Logos, icons, wallpapers, boot visuals
├── config/        # Build and package configuration
├── device/        # Device-specific configurations
├── docs/          # Architecture and development documentation
├── kde/           # KDE/Plasma customization
├── kernel/        # Kernel integration/build configuration
├── scripts/       # Build and development scripts
└── build/         # Local/generated build output (ignored)
```

## Development

The first development environment will target Windows + WSL2 + Ubuntu for ARM64 cross-development.

The project will prioritize reproducible builds and will keep generated artifacts out of Git.

## License

BookOS project files are licensed under the MIT License unless a subdirectory or component states otherwise. Third-party components retain their respective licenses.
