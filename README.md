# omarchy-openclaw 🦀

> Ultra-lightweight top bar toggle and controller for the OpenClaw Gateway on [Omarchy OS](https://omarchy.org/).

Run OpenClaw on-demand with zero background RAM consumption and full memory controls directly from your status bar.

---

## ✨ Features

- **⚡ Zero Idle RAM**: Popup content is loaded lazily on-demand. When idle on your bar, it consumes virtually 0 MB memory.
- **🛑 Start & Stop Controls**: Toggle the `openclaw-gateway` user service with a single click.
- **💡 Live Visual Status**:
  - **Online**: Bright clawbot icon with glowing green indicator dot.
  - **Offline**: Dimmed clawbot icon.
- **🚀 Quick Launchers**: Direct buttons to launch the Web Dashboard or terminal TUI.
- **🎨 Native Omarchy UI**: Built with pure Quickshell and Qt Quick, 100% solid high-contrast card, matching your system theme.

---

## 📦 Installation

### Option 1: Git Clone (Direct)

Clone into your user plugins directory:

```bash
git clone https://github.com/MaenExists/omarchy-openclaw.git ~/.config/omarchy/plugins/maen.openclaw
```

### Option 2: Add to `~/.config/omarchy/shell.json`

Add `{"id": "maen.openclaw"}` to `bar.layout.right` in `~/.config/omarchy/shell.json`:

```json
{
  "bar": {
    "layout": {
      "right": [
        { "id": "maen.openclaw" }
      ]
    }
  }
}
```

Reload the shell or let Omarchy auto-detect:

```bash
omarchy restart shell
```

---

## 🛠 Recommended OpenClaw Service Setup

For optimal performance on systems with low or moderate RAM (e.g. 4GB - 8GB), disable background autostart:

```bash
systemctl --user disable openclaw-gateway.service
```

Optionally cap Node's heap space in `~/.config/systemd/user/openclaw-gateway.service.d/override.conf`:

```ini
[Service]
ExecStart=
ExecStart=/home/maen/.openclaw/tools/node-v24.21.0/bin/node --max-old-space-size=512 /home/maen/.openclaw/tools/node-v24.21.0/lib/node_modules/openclaw/dist/index.js gateway --port 18789
MemoryHigh=512M
MemoryMax=650M
TimeoutStopSec=15
```

---

## 📄 License

MIT © [MaenExists](https://github.com/MaenExists)
