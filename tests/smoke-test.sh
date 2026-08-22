#!/usr/bin/env bash

set -euo pipefail

PROJECT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/capture-card-player-test.XXXXXX")"
trap 'rm -r -- "$TEST_ROOT"' EXIT

bash -n \
  "$PROJECT_DIR/capture-card-player" \
  "$PROJECT_DIR/install.sh" \
  "$PROJECT_DIR/publish-to-github.sh" \
  "$PROJECT_DIR/uninstall.sh"

# shellcheck disable=SC1091
source "$PROJECT_DIR/capture-card-player"

pactl() {
  case "$*" in
    "list sources")
      printf '%s\n' \
        'Source #1' \
        '    Name: alsa_input.usb-test' \
        '    Description: USB Test Capture' \
        'Source #2' \
        '    Name: alsa_output.test.monitor' \
        '    Description: Monitor'
      ;;
    "list sinks")
      printf '%s\n' \
        'Sink #1' \
        '    Name: alsa_output.pci-test' \
        '    Description: PCIe Headphones'
      ;;
    "list short sources")
      printf '1\talsa_input.usb-test\tPipeWire\n'
      printf '2\talsa_output.test.monitor\tPipeWire\n'
      ;;
    "list short sinks")
      printf '3\talsa_output.pci-test\tPipeWire\n'
      ;;
  esac
}
parec() { :; }
pacat() { :; }

find_audio_devices
[[ "$AUDIO_BACKEND" == "pulse" ]]
[[ "${SOURCE_VALUES[1]}" == "alsa_input.usb-test" ]]
[[ "${SOURCE_LABELS[1]}" == "USB Test Capture" ]]
[[ ${#SOURCE_VALUES[@]} -eq 2 ]]
[[ "${SINK_VALUES[1]}" == "alsa_output.pci-test" ]]
[[ "${SINK_LABELS[1]}" == "PCIe Headphones" ]]
printf 'Pulse-Geräteauswahl: OK\n'

unset -f pactl parec pacat
wpctl() {
  printf '%s\n' \
    'Audio' \
    ' ├─ Sinks:' \
    ' │  * 45. alsa_output.pci-card [vol: 1.00]' \
    ' ├─ Sources:' \
    ' │  * 46. alsa_input.usb-card [vol: 1.00]' \
    ' ├─ Filters:'
}
pw-loopback() { :; }

find_audio_devices
[[ "$AUDIO_BACKEND" == "pipewire" ]]
[[ "${SOURCE_VALUES[1]}" == "46" ]]
[[ "${SINK_VALUES[1]}" == "45" ]]
printf 'PipeWire-Geräteauswahl: OK\n'

mkdir -p "$TEST_ROOT/bin" "$TEST_ROOT/home"
ln -s /usr/bin/true "$TEST_ROOT/bin/mpv"
HOME="$TEST_ROOT/home" PATH="$TEST_ROOT/bin:/usr/bin:/bin" \
  bash "$PROJECT_DIR/install.sh" </dev/null

[[ -x "$TEST_ROOT/home/.local/bin/capture-card-player" ]]
[[ -f "$TEST_ROOT/home/.local/share/applications/capture-card-player.desktop" ]]
grep -Fq "Exec=$TEST_ROOT/home/.local/bin/capture-card-player" \
  "$TEST_ROOT/home/.local/share/applications/capture-card-player.desktop"
printf 'Benutzer-Installation: OK\n'

if command -v git >/dev/null 2>&1; then
  mkdir -p "$TEST_ROOT/repository"
  cp -a "$PROJECT_DIR/." "$TEST_ROOT/repository/"
  git -C "$TEST_ROOT/repository" init -q -b main
  git -C "$TEST_ROOT/repository" config user.name "Smoke Test"
  git -C "$TEST_ROOT/repository" config user.email "smoke-test@example.invalid"
  git -C "$TEST_ROOT/repository" add .
  git -C "$TEST_ROOT/repository" commit -q -m "Smoke test"
  git -C "$TEST_ROOT/repository" ls-files --error-unmatch \
    .github/workflows/smoke-test.yml >/dev/null
  printf 'GitHub-Repository-Struktur: OK\n'
fi

printf 'Alle Smoke-Tests bestanden.\n'
