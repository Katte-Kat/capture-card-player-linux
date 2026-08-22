#!/usr/bin/env bash

set -euo pipefail

PROJECT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPOSITORY_NAME="${1:-capture-card-player-linux}"
VISIBILITY="${2:-public}"
locale="${CAPTURE_CARD_PLAYER_LANG:-${LC_ALL:-${LC_MESSAGES:-${LANG:-en}}}}"
UI_LANGUAGE="en"
if [[ "$locale" == de* || "$locale" == DE* ]]; then
  UI_LANGUAGE="de"
fi

if [[ "$VISIBILITY" != "public" && "$VISIBILITY" != "private" ]]; then
  if [[ "$UI_LANGUAGE" == "de" ]]; then
    printf 'Verwendung: bash publish-to-github.sh [Repository-Name] [public|private]\n' >&2
  else
    printf 'Usage: bash publish-to-github.sh [repository-name] [public|private]\n' >&2
  fi
  exit 2
fi

for command_name in git gh; do
  if ! command -v "$command_name" >/dev/null 2>&1; then
    if [[ "$UI_LANGUAGE" == "de" ]]; then
      printf 'Fehlender Befehl: %s\n' "$command_name" >&2
    else
      printf 'Missing command: %s\n' "$command_name" >&2
    fi
    exit 1
  fi
done

cd "$PROJECT_DIR"

if ! gh auth status >/dev/null 2>&1; then
  if [[ "$UI_LANGUAGE" == "de" ]]; then
    printf 'GitHub-Anmeldung wird gestartet.\n'
  else
    printf 'Starting GitHub authentication.\n'
  fi
  gh auth login
fi

if [[ ! -e .git ]]; then
  git init -b main
fi

if ! git config user.name >/dev/null; then
  if [[ "$UI_LANGUAGE" == "de" ]]; then
    read -r -p 'Name für Git-Commits: ' git_name
  else
    read -r -p 'Name for Git commits: ' git_name
  fi
  git config user.name "$git_name"
fi

if ! git config user.email >/dev/null; then
  if [[ "$UI_LANGUAGE" == "de" ]]; then
    read -r -p 'E-Mail für Git-Commits: ' git_email
  else
    read -r -p 'Email for Git commits: ' git_email
  fi
  git config user.email "$git_email"
fi

git add .
if ! git diff --cached --quiet; then
  git commit -m "Initial release"
fi

git branch -M main

if git remote get-url origin >/dev/null 2>&1; then
  if [[ "$UI_LANGUAGE" == "de" ]]; then
    printf 'Der Git-Remote "origin" existiert bereits.\n' >&2
    printf 'Push zum vorhandenen Remote wird ausgeführt.\n'
  else
    printf 'The Git remote "origin" already exists.\n' >&2
    printf 'Pushing to the existing remote.\n'
  fi
  git push -u origin main
  exit 0
fi

gh repo create "$REPOSITORY_NAME" \
  "--$VISIBILITY" \
  --source=. \
  --remote=origin \
  --push

if [[ "$UI_LANGUAGE" == "de" ]]; then
  printf 'Repository erfolgreich veröffentlicht.\n'
else
  printf 'Repository published successfully.\n'
fi
