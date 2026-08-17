# BookOS Architecture

## Design goal

BookOS is a tablet-first Linux distribution with a dual-mode **Fusion** experience.

```text
                         BookOS
                            │
                ┌───────────┴───────────┐
                │                       │
          Tablet Mode             Desktop Mode
                │                       │
        BookOS Fusion UI          KDE Plasma
                │                       │
                └───────────┬───────────┘
                            │
                         Wayland
                            │
                       Linux kernel
                            │
                      Debian ARM64
                            │
                       Tablet hardware
```

## Initial target

The first hardware target is the Xiaomi Redmi Pad (`yunluo`, MT6789/MT8781V / Helio G99).

Hardware-specific integration must remain isolated under `device/yunluo/` so that the BookOS userspace can eventually support additional devices.

## Development phases

### Phase 1 — Foundation

- Debian ARM64 root filesystem
- Reproducible bootstrap/build scripts
- KDE Plasma + Wayland
- Initial BookOS branding

### Phase 2 — Fusion

- Touch-first tablet shell
- Tablet/desktop workflow switching
- Quick settings and notification UX
- Performance tuning

### Phase 3 — Hardware

- `yunluo` kernel integration
- Display and touch
- GPU acceleration
- Wi-Fi/Bluetooth
- Audio
- Sensors and power management

### Phase 4 — Ecosystem

- BookOS applications
- Optional Waydroid/Android application support
- Update and packaging infrastructure

## Guiding principle

BookOS should remain recognizable as its own operating system while continuing to use upstream Linux, Debian, KDE, and other open-source components where appropriate. Upstream components should not be unnecessarily forked when configuration, theming, extensions, or separate BookOS components can achieve the same result.
