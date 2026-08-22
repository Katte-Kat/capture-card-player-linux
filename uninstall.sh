#!/usr/bin/env bash

set -u

APP_ID="capture-card-player"
BIN_DIR="${XDG_BIN_HOME:-$HOME/.local/bin}"
APPLICATIONS_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/applications"
TARGET="$BIN_DIR/$APP_ID"
DESKTOP_FILE="$APPLICATIONS_DIR/$APP_ID.desktop"

locale="${CAPTURE_CARD_PLAYER_LANG:-${LC_ALL:-${LC_MESSAGES:-${LANG:-en}}}}"
if [[ "$locale" == de* || "$locale" == DE* ]]; then
  UI_LANGUAGE="de"
else
  UI_LANGUAGE="en"
fi

rm -f -- "$TARGET" "$DESKTOP_FILE"

if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database "$APPLICATIONS_DIR" >/dev/null 2>&1 || true
fi

if [[ "$UI_LANGUAGE" == "de" ]]; then
  printf 'Capture Card Player for Linux wurde aus deinem Benutzerkonto entfernt.\n'
  printf 'Ein vorhandenes Backup bleibt gegebenenfalls unter %s.bak erhalten.\n' "$DESKTOP_FILE"
else
  printf 'Capture Card Player for Linux was removed from your user account.\n'
  printf 'An existing backup, if any, remains at %s.bak.\n' "$DESKTOP_FILE"
fi
