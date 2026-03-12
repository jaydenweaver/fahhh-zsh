# shellcheck shell=zsh

if [[ -n "${__FAHHHH_LOADED:-}" ]]; then
  return 0
fi

typeset -g __FAHHHH_LOADED=1

autoload -Uz add-zsh-hook

typeset -g FAHHHH_ROOT_DIR="${${(%):-%N}:A:h}"
typeset -g FAHHHH_SOUND_FILE="${FAHHHH_SOUND_FILE:-${FAHHHH_ROOT_DIR}/fahhh.mp3}"
typeset -g FAHHHH_ENABLED="${FAHHHH_ENABLED:-1}"
typeset -g FAHHHH_GLOBAL="${FAHHHH_GLOBAL:-0}"
typeset -g FAHHHH_LAST_COMMAND=""
typeset -gi __FAHHHH_COMMAND_SEEN=0
typeset -gi __FAHHHH_HOOKS_ACTIVE=0

__fahhh_enable_hooks() {
  emulate -L zsh

  if (( __FAHHHH_HOOKS_ACTIVE == 1 )); then
    return 0
  fi

  add-zsh-hook preexec __fahhh_preexec
  add-zsh-hook precmd __fahhh_precmd
  typeset -gi __FAHHHH_HOOKS_ACTIVE=1
}

__fahhh_disable_hooks() {
  emulate -L zsh

  if (( __FAHHHH_HOOKS_ACTIVE == 0 )); then
    return 0
  fi

  add-zsh-hook -d preexec __fahhh_preexec >/dev/null 2>&1 || true
  add-zsh-hook -d precmd __fahhh_precmd >/dev/null 2>&1 || true
  typeset -gi __FAHHHH_COMMAND_SEEN=0
  typeset -gi __FAHHHH_HOOKS_ACTIVE=0
}

__fahhh_matches_test_command() {
  emulate -L zsh

  local command_text="${1:l}"
  local -a patterns

  patterns=(
    '(^|[[:space:];|&])(npm[[:space:]]+(test|t))($|[[:space:];|&])'
    '(^|[[:space:];|&])npm[[:space:]]+run[[:space:]]+test($|[[:space:];|&])'
    '(^|[[:space:];|&])((pnpm|yarn|bun)[[:space:]]+(test|t))($|[[:space:];|&])'
    '(^|[[:space:];|&])(jest|vitest|mocha|pytest|cargo[[:space:]]+test|go[[:space:]]+test)($|[[:space:];|&])'
    '(^|[[:space:];|&])(nosetests|tox|rspec|phpunit)($|[[:space:];|&])'
    '(^|[[:space:];|&])((mvn|mvnw)[[:space:]].*test)($|[[:space:];|&])'
    '(^|[[:space:];|&])((gradle|gradlew|./gradlew)[[:space:]].*test)($|[[:space:];|&])'
  )

  local pattern
  for pattern in "${patterns[@]}"; do
    if [[ $command_text =~ $pattern ]]; then
      return 0
    fi
  done

  return 1
}

__fahhh_should_play_for_command() {
  emulate -L zsh

  if [[ "${FAHHHH_ENABLED}" != "1" ]]; then
    return 1
  fi

  if [[ "${FAHHHH_GLOBAL}" == "1" ]]; then
    return 0
  fi

  __fahhh_matches_test_command "$1"
}

__fahhh_play_sound() {
  emulate -L zsh

  if ! command -v afplay >/dev/null 2>&1; then
    return 1
  fi

  if [[ ! -f "${FAHHHH_SOUND_FILE}" ]]; then
    return 1
  fi

  (command afplay "${FAHHHH_SOUND_FILE}" >/dev/null 2>&1) &!
}

__fahhh_preexec() {
  emulate -L zsh

  typeset -g FAHHHH_LAST_COMMAND="$1"
  typeset -gi __FAHHHH_COMMAND_SEEN=1
}

__fahhh_precmd() {
  local exit_status="$?"
  local command_text="${FAHHHH_LAST_COMMAND}"

  emulate -L zsh

  if (( __FAHHHH_COMMAND_SEEN == 0 )); then
    return 0
  fi

  typeset -gi __FAHHHH_COMMAND_SEEN=0

  if (( exit_status == 0 )); then
    return 0
  fi

  if ! __fahhh_should_play_for_command "${command_text}"; then
    return 0
  fi

  __fahhh_play_sound
}

fahhh-on() {
  emulate -L zsh

  typeset -g FAHHHH_ENABLED=1
  __fahhh_enable_hooks
  print 'fahhh-zsh enabled'
}

fahhh-off() {
  emulate -L zsh

  typeset -g FAHHHH_ENABLED=0
  __fahhh_disable_hooks
  print 'fahhh-zsh disabled'
}

fahhh-status() {
  emulate -L zsh

  local state='disabled'
  local mode='test failures only'
  local sound_state='missing'
  local player_state='missing'

  if [[ "${FAHHHH_ENABLED}" == "1" ]]; then
    state='enabled'
  fi

  if [[ "${FAHHHH_GLOBAL}" == "1" ]]; then
    mode='all failures'
  fi

  if [[ -f "${FAHHHH_SOUND_FILE}" ]]; then
    sound_state='present'
  fi

  if command -v afplay >/dev/null 2>&1; then
    player_state='available'
  fi

  print "fahhh-zsh ${state}"
  print "mode: ${mode}"
  print "sound: ${FAHHHH_SOUND_FILE} (${sound_state})"
  print "player: afplay (${player_state})"
}

fahhh() {
  emulate -L zsh

  if __fahhh_play_sound; then
    return 0
  fi

  if ! command -v afplay >/dev/null 2>&1; then
    print -u2 'fahhh-zsh: afplay is not available'
    return 1
  fi

  if [[ ! -f "${FAHHHH_SOUND_FILE}" ]]; then
    print -u2 "fahhh-zsh: sound file not found at ${FAHHHH_SOUND_FILE}"
    return 1
  fi

  print -u2 'fahhh-zsh: failed to start playback'
  return 1
}

if [[ "${FAHHHH_ENABLED}" == "1" ]]; then
  __fahhh_enable_hooks
fi
