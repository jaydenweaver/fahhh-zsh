# fahhh-zsh

A lightweight zsh hook that plays `fahhh.mp3` when a command fails using `afplay`.

<img src="fahhh.jpeg" alt="FAHHH" width="300" height="300">

## Files

- `fahhh.zsh`: sourceable plugin with the hooks and shell commands
- `install.sh`: appends a guarded source block to `~/.zshrc`
- `uninstall.sh`: removes that block from `~/.zshrc`
- `fahhh.mp3`: sound file

## Prerequisites

- macOS with `zsh` and `afplay` (should come default)

## Install

Run:

```bash
chmod +x ./install.sh ./uninstall.sh
./install.sh
```

Reload your shell with:

```bash
source ./fahhh.zsh
```

## Usage

Default behavior: play the sound only when a failed command looks like a test runner.

Recognized patterns include:

- `npm test`
- `npm t`
- `npm run test`
- `pnpm test`
- `yarn test`
- `jest`
- `vitest`
- `mocha`
- `pytest`
- `cargo test`
- `go test`

Runtime commands:

```zsh
fahhh
fahhh-on
fahhh-off
fahhh-status
```

`fahhh` plays the configured sound immediately, even if failure-trigger mode is disabled.

Manual playback example:

```zsh
fahhh
```

If `afplay` is unavailable or the sound file is missing, the command exits non-zero and prints a short error to stderr.

Example status output:

```text
fahhh-zsh enabled
mode: test failures only
sound: /path/to/fahhh-zsh/fahhh.mp3 (present)
player: afplay (available)
```

## Global Mode

To play on any non-zero exit code, set `FAHHHH_GLOBAL=1` before the plugin is sourced:

```zsh
export FAHHHH_GLOBAL=1
source "./fahhh.zsh"
```

You can also set a custom sound path:

```zsh
export FAHHHH_SOUND_FILE="$HOME/sounds/fahhh.mp3"
source "./fahhh.zsh"
```

## Uninstall

Run:

```bash
./uninstall.sh
```

This removes the managed block from `~/.zshrc`. Restart `zsh` to fully unload the functions and hooks from the current shell session.
