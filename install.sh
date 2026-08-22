#!/usr/bin/env bash

set -u

APP_NAME="Capture Card Player for Linux"
APP_ID="capture-card-player"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="${XDG_BIN_HOME:-$HOME/.local/bin}"
APPLICATIONS_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/applications"
TARGET="$BIN_DIR/$APP_ID"
DESKTOP_FILE="$APPLICATIONS_DIR/$APP_ID.desktop"

ask_yes_no() {
  local prompt="$1"
  local answer
  read -r -p "$prompt [J/n] " answer
  [[ -z "$answer" || "$answer" =~ ^[JjYy]$ ]]
}

install_flatpak_mpv() {
  if ! command -v flatpak >/dev/null 2>&1; then
    return 1
  fi

  if flatpak info io.mpv.Mpv >/dev/null 2>&1; then
    return 0
  fi

  printf '\nmpv ist nicht installiert. Der portable Weg für Bazzite/SteamOS ist Flathub.\n'
  if ! ask_yes_no "mpv jetzt als Benutzer-Flatpak installieren?"; then
    return 1
  fi

  if ! flatpak remote-list --user --columns=name 2>/dev/null | grep -Fxq flathub; then
    flatpak remote-add --user --if-not-exists flathub \
      https://dl.flathub.org/repo/flathub.flatpakrepo || return 1
  fi
  flatpak install --user -y flathub io.mpv.Mpv
}

install_native_arch_mpv() {
  command -v pacman >/dev/null 2>&1 || return 1
  ask_yes_no "mpv und PulseAudio-Werkzeuge mit pacman installieren?" || return 1
  sudo pacman -S --needed mpv libpulse
}

install_native_fedora_mpv() {
  command -v dnf >/dev/null 2>&1 || return 1
  ask_yes_no "mpv und PulseAudio-Werkzeuge mit dnf installieren?" || return 1
  sudo dnf install -y mpv pulseaudio-utils
}

ensure_dependencies() {
  if command -v mpv >/dev/null 2>&1 || { command -v flatpak >/dev/null 2>&1 && flatpak info io.mpv.Mpv >/dev/null 2>&1; }; then
    return 0
  fi

  local os_id="" os_like="" variant=""
  if [[ -r /etc/os-release ]]; then
    # shellcheck disable=SC1091
    source /etc/os-release
    os_id="${ID:-}"
    os_like="${ID_LIKE:-}"
    variant="${VARIANT_ID:-}"
  fi

  if [[ "$os_id" == "bazzite" || "$os_id" == "steamos" || "$variant" == *"atomic"* || -e /run/ostree-booted ]]; then
    install_flatpak_mpv
    return $?
  fi

  if command -v flatpak >/dev/null 2>&1; then
    install_flatpak_mpv && return 0
  fi

  if [[ "$os_id" == "arch" || "$os_id" == "cachyos" || "$os_like" == *"arch"* ]]; then
    install_native_arch_mpv
    return $?
  fi

  if [[ "$os_id" == "fedora" || "$os_like" == *"fedora"* ]]; then
    install_native_fedora_mpv
    return $?
  fi

  return 1
}

main() {
  printf '%s – Installation\n' "$APP_NAME"
  printf 'Installiert nur Dateien im Benutzerkonto.\n\n'

  if ! ensure_dependencies; then
    printf '\nHinweis: mpv konnte nicht automatisch installiert werden.\n' >&2
    printf 'Die App wird trotzdem eingerichtet, startet aber erst nach der mpv-Installation.\n' >&2
  fi

  mkdir -p "$BIN_DIR" "$APPLICATIONS_DIR"
  install -m 0755 "$SCRIPT_DIR/capture-card-player" "$TARGET"

  if [[ -f "$DESKTOP_FILE" ]]; then
    cp -a "$DESKTOP_FILE" "$DESKTOP_FILE.bak"
  fi

  {
    printf '%s\n' '[Desktop Entry]'
    printf '%s\n' 'Type=Application'
    printf 'Name=%s\n' "$APP_NAME"
    printf '%s\n' 'Comment=USB- oder PCIe-Capture-Karte mit geringer Verzögerung anzeigen'
    printf 'Exec=%s\n' "$TARGET"
    printf '%s\n' 'Icon=camera-video'
    printf '%s\n' 'Terminal=false'
    printf '%s\n' 'Categories=AudioVideo;Video;'
    printf '%s\n' 'StartupNotify=true'
  } > "$DESKTOP_FILE"

  if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database "$APPLICATIONS_DIR" >/dev/null 2>&1 || true
  fi

  printf '\nFertig. Öffne „%s“ im App-Menü.\n' "$APP_NAME"
  printf 'Beim Start wählst du Videoeingang, Audioeingang und Audioausgang aus.\n'

  if ! { command -v pactl >/dev/null 2>&1 && command -v parec >/dev/null 2>&1 && command -v pacat >/dev/null 2>&1; } && \
     ! { command -v wpctl >/dev/null 2>&1 && command -v pw-loopback >/dev/null 2>&1; }; then
    printf '\nWARNUNG: Audio-Werkzeuge fehlen. Video funktioniert, Audio erst nach Installation von\n' >&2
    printf 'pactl/parec/pacat (libpulse bzw. pulseaudio-utils) oder wpctl/pw-loopback.\n' >&2
  fi
}

main "$@"
