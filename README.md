# Architect

Architect is a Nix-like configuration manager for Arch GNU/Linux’s pacman, designed to handle system packages, package snapshots, AUR builds, dotfiles, and more.

## Features

- Define package groups and manage them declaratively
- Automatic snapshots with rollback, diff, and apply-diff
- AUR support without heavy helpers, including `--install-aur-only`
- Dotfiles syncing, status, and editing
- Dry-run support for safe testing
- Snapshots management: list, purge, rollback
- Configurable via a single bash config file
- Modular codebase for easy maintenance and extension
- And more! :3

## Installation

```bash
git clone https://github.com/neoapps-dev/architect.git
cd architect
make
sudo make install
```

## Usage

Basic commands:

```bash
architect --help
architect --list-snapshots
architect --take-snapshot-now
architect --install-aur-only
architect --rollback
architect --dotfiles-sync
```

You can define your package sets in the config file, for example:

```bash
declare -A packages_by_set=(
  [base]="bash coreutils linux linux-firmware"
  [dev]="git gcc make gdb"
  [media]="mpv ffmpeg vlc"
)

system_packages=(
  base
  dev
  media
)
```

## Configuration

Edit `/etc/architect.sh` or set `ARCHITECT_CONFIG` environment variable to point to your custom config.

## Development

Architect is modularized under `src/` with:

* `install.sh` — package resolution and installation
* `snapshots.sh` — snapshot management
* `validate.sh` — validate config file logic
* `dotfiles.sh` — dotfiles management
* `z.sh` — command-line parsing (must be last)
* `misc.sh` — helper functions
* `test.sh` — self-test functions
* `main.sh` — environment setup and config sourcing
* `pacstrap.sh` — pacstrap pacman wrapper support
* `diff.sh` — shows diff between config and current env, and apply diff function

The [Makefile](Makefile) builds a standalone executable by concatenating all source files.

## Contributing

Feel free to open issues, submit PRs, or suggest features!

## License

GPLv3 License — see [LICENSE](LICENSE) file.
