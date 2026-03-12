#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_PATH="${SCRIPT_DIR}/fahhh.zsh"
ZSHRC_PATH="${ZDOTDIR:-$HOME}/.zshrc"
START_MARKER="# >>> fahhh-zsh >>>"
END_MARKER="# <<< fahhh-zsh <<<"

if [[ ! -f "${PLUGIN_PATH}" ]]; then
  echo "Missing plugin file: ${PLUGIN_PATH}" >&2
  exit 1
fi

mkdir -p "$(dirname "${ZSHRC_PATH}")"
touch "${ZSHRC_PATH}"

if grep -Fq "${START_MARKER}" "${ZSHRC_PATH}"; then
  echo "fahhh-zsh is already installed in ${ZSHRC_PATH}"
  echo "Restart zsh or run: source \"${PLUGIN_PATH}\""
  exit 0
fi

{
  printf '\n%s\n' "${START_MARKER}"
  printf 'source "%s"\n' "${PLUGIN_PATH}"
  printf '%s\n' "${END_MARKER}"
} >> "${ZSHRC_PATH}"

echo "Installed fahhh-zsh into ${ZSHRC_PATH}"
echo "Restart zsh or run: source \"${PLUGIN_PATH}\""
