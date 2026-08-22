# Capture Card Player for Linux

[English](README.md) | [Deutsch](README.de.md)

[![Smoke test](https://github.com/Katte-Kat/capture-card-player-linux/actions/workflows/smoke-test.yml/badge.svg)](https://github.com/Katte-Kat/capture-card-player-linux/actions/workflows/smoke-test.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

A small Linux application for viewing and playing through a capture card with minimal display latency. At launch, you can select the video input, audio input, and audio output.

USB and PCIe capture cards are detected in the same way. A card is supported when Linux exposes it as a standard V4L2 device under `/dev/video*`. Audio is selected separately through PipeWire or PulseAudio, which also supports PCIe cards that expose audio as a separate input.

## Features

- Select a video input at every launch
- Select any available PipeWire or PulseAudio input
- Select a specific audio output or use the system default
- Supports USB and PCIe capture cards
- Identifies devices as USB or PCIe when that information is available
- Separate low-latency video and audio paths
- Native mpv and Flathub mpv support
- KDialog, Zenity, or terminal interface
- Automatic English/German interface based on the system locale
- Per-user installation without writing application files to system directories

## Supported systems

| System | Supported setup |
| --- | --- |
| Arch Linux / CachyOS | Native mpv or Flatpak |
| Fedora | Native mpv or Flatpak |
| Bazzite | Flathub mpv in Desktop Mode |
| SteamOS | Flathub mpv in Desktop Mode |

A functional Linux driver is still required for the capture card. Elgato cards can work when they appear as standard V4L2 devices. Cards that are only available through a vendor-specific OBS plugin are not supported directly.

## Installation

Clone the repository and run the installer:

```bash
git clone https://github.com/Katte-Kat/capture-card-player-linux.git
cd capture-card-player-linux
bash install.sh
```

Then launch **Capture Card Player for Linux** from the application menu and optionally pin it to the taskbar.

The installer writes application files only to:

- `~/.local/bin`
- `~/.local/share/applications`

If mpv is missing, the installer offers to install the Flathub mpv package on Bazzite/SteamOS or an appropriate native package on standard Arch/Fedora systems.

## Usage

The application asks for these selections at launch:

1. Video input
2. Audio input or **No audio**
3. Audio output or **System default**

**System default** uses the output that is active when playback starts. If you change the system output while playing and the stream does not move automatically, restart the application.

Video runs separately with:

```text
--profile=low-latency --untimed --no-audio
```

This prevents audio synchronization from introducing a visible video buffer. Press `F` in mpv to toggle fullscreen mode and `Q` to close the player and stop the audio stream.

## Language

The application, installer, and uninstaller automatically use German when the active locale starts with `de`; otherwise they use English. Override the detected language when needed:

```bash
CAPTURE_CARD_PLAYER_LANG=en capture-card-player
CAPTURE_CARD_PLAYER_LANG=de capture-card-player
```

## Bazzite and SteamOS

Install and test the application in Desktop Mode. To launch it from Gaming Mode afterward, add it through **Add a Game → Add a Non-Steam Game**. Device selection is most reliable in Desktop Mode.

## Troubleshooting

- **No video source:** Run `ls -l /dev/video*`. OBS or another application must not have the card open at the same time.
- **Several video sources have the same name:** Test them one at a time. Capture cards often expose more than one V4L2 node.
- **No audio source:** Run `pactl list short sources`. A PCIe card may expose audio as a separate ALSA/PipeWire input.
- **No audio playback:** Arch/CachyOS typically needs `libpulse`; Fedora typically needs `pulseaudio-utils`. `wpctl` and `pw-loopback` from PipeWire are also supported.
- **Flathub mpv cannot access the card:** Run `flatpak override --user --device=all io.mpv.Mpv`, then try again.
- **The card only appears through an OBS plugin:** The application requires a standard V4L2 `/dev/video*` device.

## Uninstallation

From the cloned project directory, run:

```bash
bash uninstall.sh
```

An existing backup of the desktop entry is intentionally left in place.

## Development

Run the local smoke tests with:

```bash
bash tests/smoke-test.sh
```

The GitHub Actions workflow runs the same tests automatically for pushes and pull requests.

The smoke test uses an isolated temporary directory and does not modify the installed application or the real home directory.

## License

Distributed under the MIT License. See [LICENSE](LICENSE).

*Created with AI assistance.*
