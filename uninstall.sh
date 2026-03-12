#!/usr/bin/env bash

set -euo pipefail

ZSHRC_PATH="${ZDOTDIR:-$HOME}/.zshrc"
START_MARKER="# >>> fahhh-zsh >>>"
END_MARKER="# <<< fahhh-zsh <<<"

if [[ ! -f "${ZSHRC_PATH}" ]]; then
  echo "No ${ZSHRC_PATH} found"
  exit 0
fi

TMP_FILE="$(mktemp)"
trap 'rm -f "${TMP_FILE}"' EXIT

awk -v start="${START_MARKER}" -v end="${END_MARKER}" '
  $0 == start { skip = 1; next }
  $0 == end { skip = 0; next }
  skip == 0 { print }
' "${ZSHRC_PATH}" > "${TMP_FILE}"

if cmp -s "${ZSHRC_PATH}" "${TMP_FILE}"; then
  rm -f "${TMP_FILE}"
  echo "fahhh-zsh is not installed in ${ZSHRC_PATH}"
  exit 0
fi

mv "${TMP_FILE}" "${ZSHRC_PATH}"
trap - EXIT

echo "Removed fahhh-zsh from ${ZSHRC_PATH}"
echo "Restart zsh to unload the current shell session."
