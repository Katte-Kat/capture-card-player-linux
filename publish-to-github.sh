#!/usr/bin/env bash

set -euo pipefail

PROJECT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPOSITORY_NAME="${1:-capture-card-player-linux}"
VISIBILITY="${2:-public}"

if [[ "$VISIBILITY" != "public" && "$VISIBILITY" != "private" ]]; then
  printf 'Verwendung: bash publish-to-github.sh [repository-name] [public|private]\n' >&2
  exit 2
fi

for command_name in git gh; do
  if ! command -v "$command_name" >/dev/null 2>&1; then
    printf 'Fehlt: %s\n' "$command_name" >&2
    exit 1
  fi
done

cd "$PROJECT_DIR"

if ! gh auth status >/dev/null 2>&1; then
  printf 'GitHub-Anmeldung wird gestartet.\n'
  gh auth login
fi

if [[ ! -e .git ]]; then
  git init -b main
fi

if ! git config user.name >/dev/null; then
  read -r -p 'Name für Git-Commits: ' git_name
  git config user.name "$git_name"
fi

if ! git config user.email >/dev/null; then
  read -r -p 'E-Mail für Git-Commits: ' git_email
  git config user.email "$git_email"
fi

git add .
if ! git diff --cached --quiet; then
  git commit -m "Initial release"
fi

git branch -M main

if git remote get-url origin >/dev/null 2>&1; then
  printf 'Der Git-Remote „origin“ existiert bereits.\n' >&2
  printf 'Push wird mit dem vorhandenen Remote ausgeführt.\n'
  git push -u origin main
  exit 0
fi

gh repo create "$REPOSITORY_NAME" \
  "--$VISIBILITY" \
  --source=. \
  --remote=origin \
  --push

printf 'Repository wurde veröffentlicht.\n'
