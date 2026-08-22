#!/usr/bin/env bash

set -u

APP_NAME="Capture Card Player for Linux"
APP_ID="capture-card-player"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="${XDG_BIN_HOME:-$HOME/.local/bin}"
APPLICATIONS_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/applications"
TARGET="$BIN_DIR/$APP_ID"
DESKTOP_FILE="$APPLICATIONS_DIR/$APP_ID.desktop"
UI_LANGUAGE="en"

detect_ui_language() {
  local locale="${CAPTURE_CARD_PLAYER_LANG:-${LC_ALL:-${LC_MESSAGES:-${LANG:-en}}}}"
  case "$locale" in
    de*|DE*) UI_LANGUAGE="de" ;;
    *) UI_LANGUAGE="en" ;;
  esac
}

text_for() {
  local key="$1"
  local english="" german=""

  case "$key" in
    yes_no_hint)
      english="[Y/n]"
      german="[J/n]"
      ;;
    flatpak_note)
      english="mpv is not installed. Flathub is the portable option for Bazzite/SteamOS."
      german="mpv ist nicht installiert. Flathub ist die portable Option für Bazzite/SteamOS."
      ;;
    install_flatpak)
      english="Install mpv as a per-user Flatpak now?"
      german="mpv jetzt als Flatpak für diesen Benutzer installieren?"
      ;;
    install_arch)
      english="Install mpv and the PulseAudio tools with pacman?"
      german="mpv und die PulseAudio-Werkzeuge mit pacman installieren?"
      ;;
    install_fedora)
      english="Install mpv and the PulseAudio tools with dnf?"
      german="mpv und die PulseAudio-Werkzeuge mit dnf installieren?"
      ;;
    install_heading)
      english="Installation"
      german="Installation"
      ;;
    per_user_only)
      english="Only files in the current user account will be installed."
      german="Es werden nur Dateien im aktuellen Benutzerkonto installiert."
      ;;
    mpv_failed_note)
      english="Note: mpv could not be installed automatically."
      german="Hinweis: mpv konnte nicht automatisch installiert werden."
      ;;
    mpv_failed_result)
      english="The app will still be installed, but it will not start until mpv is available."
      german="Die App wird trotzdem installiert, startet aber erst, wenn mpv verfügbar ist."
      ;;
    done)
      english="Done. Open \"%s\" from the application menu."
      german="Fertig. Öffne \"%s\" über das Anwendungsmenü."
      ;;
    choose_devices)
      english="At launch, select the video input, audio input, and audio output."
      german="Beim Start wählst du Videoeingang, Audioeingang und Audioausgang aus."
      ;;
    audio_warning)
      english="WARNING: Audio tools are missing. Video will work, but audio requires"
      german="WARNUNG: Audio-Werkzeuge fehlen. Video funktioniert, aber Audio benötigt"
      ;;
    audio_packages)
      english="pactl/parec/pacat (libpulse or pulseaudio-utils) or wpctl/pw-loopback."
      german="pactl/parec/pacat (libpulse oder pulseaudio-utils) oder wpctl/pw-loopback."
      ;;
    *)
      english="$key"
      german="$key"
      ;;
  esac

  if [[ "$UI_LANGUAGE" == "de" ]]; then
    printf '%s' "$german"
  else
    printf '%s' "$english"
  fi
}

detect_ui_language

ask_yes_no() {
  local prompt="$1"
  local answer
  read -r -p "$prompt $(text_for yes_no_hint) " answer
  [[ -z "$answer" || "$answer" =~ ^[JjYy]$ ]]
}

install_flatpak_mpv() {
  if ! command -v flatpak >/dev/null 2>&1; then
    return 1
  fi

  if flatpak info io.mpv.Mpv >/dev/null 2>&1; then
    return 0
  fi

  printf '\n%s\n' "$(text_for flatpak_note)"
  if ! ask_yes_no "$(text_for install_flatpak)"; then
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
  ask_yes_no "$(text_for install_arch)" || return 1
  sudo pacman -S --needed mpv libpulse
}

install_native_fedora_mpv() {
  command -v dnf >/dev/null 2>&1 || return 1
  ask_yes_no "$(text_for install_fedora)" || return 1
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
  printf '%s - %s\n' "$APP_NAME" "$(text_for install_heading)"
  printf '%s\n\n' "$(text_for per_user_only)"

  if ! ensure_dependencies; then
    printf '\n%s\n' "$(text_for mpv_failed_note)" >&2
    printf '%s\n' "$(text_for mpv_failed_result)" >&2
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
    printf '%s\n' 'Comment=View a USB or PCIe capture card with low latency'
    printf '%s\n' 'Comment[de]=USB- oder PCIe-Capture-Karte mit geringer Verzögerung anzeigen'
    printf 'Exec=%s\n' "$TARGET"
    printf '%s\n' 'Icon=camera-video'
    printf '%s\n' 'Terminal=false'
    printf '%s\n' 'Categories=AudioVideo;Video;'
    printf '%s\n' 'StartupNotify=true'
  } > "$DESKTOP_FILE"

  if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database "$APPLICATIONS_DIR" >/dev/null 2>&1 || true
  fi

  local done_message
  printf -v done_message "$(text_for done)" "$APP_NAME"
  printf '\n%s\n' "$done_message"
  printf '%s\n' "$(text_for choose_devices)"

  if ! { command -v pactl >/dev/null 2>&1 && command -v parec >/dev/null 2>&1 && command -v pacat >/dev/null 2>&1; } && \
     ! { command -v wpctl >/dev/null 2>&1 && command -v pw-loopback >/dev/null 2>&1; }; then
    printf '\n%s\n' "$(text_for audio_warning)" >&2
    printf '%s\n' "$(text_for audio_packages)" >&2
  fi
}

main "$@"
