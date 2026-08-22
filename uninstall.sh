#!/usr/bin/env bash

set -u

APP_ID="capture-card-player"
BIN_DIR="${XDG_BIN_HOME:-$HOME/.local/bin}"
APPLICATIONS_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/applications"
TARGET="$BIN_DIR/$APP_ID"
DESKTOP_FILE="$APPLICATIONS_DIR/$APP_ID.desktop"

rm -f -- "$TARGET" "$DESKTOP_FILE"

if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database "$APPLICATIONS_DIR" >/dev/null 2>&1 || true
fi

printf 'Capture Card Player for Linux wurde aus deinem Benutzerkonto entfernt.\n'
printf 'Ein vorhandenes Backup bleibt ggf. unter %s.bak erhalten.\n' "$DESKTOP_FILE"
