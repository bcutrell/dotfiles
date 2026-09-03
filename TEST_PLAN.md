# Test Plan

Verifies `setup.sh`, `clean.sh` and the Neovim config. Linux is tested in
containers via `docker-test.sh`; macOS is verified manually.

## Prerequisites

- Docker running (for the Linux tests)
- Commands run from the repo root

```bash
./docker-test.sh build
```

## Scope

| Area | Covered by |
|------|-----------|
| POSIX compliance | `sh -n` on every script, run under Debian's `dash` |
| `setup.sh` tiers | `test_minimal`, `test_full` |
| Linking + backup | `test_minimal`, `test_unlink` |
| Shell cleanliness | `test_shell_clean` |
| Neovim config | `test_nvim` |

---

## 1. Automated (Debian + Ubuntu)

```bash
./docker-test.sh test        # both distros
./docker-test.sh test debian # one distro
```

Each check exits non-zero on failure, so the suite genuinely fails. Specifically:

**1.1 syntax** — `sh -n setup.sh clean.sh lib.sh`. These must parse as POSIX
`sh`, not just bash: Debian's `/bin/sh` is dash.

**1.2 minimal install + link** — runs `sh setup.sh --minimal --yes`, then asserts:
- `stow` is **not** installed (setup.sh must not depend on it)
- `git curl tmux vim` are on PATH
- every minimal-tier target is a symlink and resolves (not dangling)
- `~/.vimrc` is the plugin-free `vim-light` one
- `~/.config/nvim` was **not** linked
- `~/.gitconfig.local` was generated

**1.3 shells start clean** — asserts an interactive bash prints nothing on
startup (catches the unguarded-`starship` class of bug), that
`core.excludesfile` actually resolves on Linux, and that `osxkeychain` never
leaks into a Linux git config.

**1.4 unlink round-trip** — plants a real `~/.zshrc`, installs over it, then
`clean.sh unlink`. Asserts the symlink is gone and the original content is
restored from the backup.

**1.5 full install** — `./docker-test.sh test-full`. Asserts `nvim git node rg
tmux zsh` are present and `~/.config/nvim` is linked. Slow.

**1.6 Neovim loads** — `./docker-test.sh test-nvim`. Asserts headless Neovim
prints `CONFIG LOADED` and that no `E###:` error appears in the output.

**1.7 cleanup** — `./docker-test.sh cleanup`.

## 2. arm64

The Neovim install is arch-aware (`nvim-linux-arm64` vs `nvim-linux-x86_64`).
On an arm64 host this is covered by the normal run; on x86_64, force it:

```bash
docker build --platform linux/arm64 --build-arg BASE_IMAGE=debian:12 -t dotfiles-arm64 .
docker run --rm --platform linux/arm64 dotfiles-arm64 sh setup.sh --full --yes
```

## 3. Tier matrix

| Command | Neovim? | `~/.vimrc` source | Homebrew (macOS)? |
|---------|---------|-------------------|-------------------|
| `sh setup.sh --minimal` | no | `vim-light/.vimrc` | never |
| `sh setup.sh --full` | yes | `vim/.vimrc` | yes, prompts first |
| `sh setup.sh --link-only` | no | per tier | no |
| `sh setup.sh --check` | — | — | no (read-only) |

Also confirm:
- Re-running the same tier reports `ok` for each link and creates **no** new backup.
- Switching `--minimal` → `--full` re-points `~/.vimrc` and adds the nvim/starship links.
- EOF on stdin (`sh setup.sh < /dev/null`) falls back to `minimal` rather than hanging.

## 4. Manual — macOS

```bash
sh setup.sh --full
```

- Homebrew prompts before installing; **no** `brew upgrade`/`cleanup` runs
  (that was the slowest thing in the old script).
- `~/.gitconfig.local` gets `helper = osxkeychain`; on Linux it gets `cache`.
- `nvim` → `:checkhealth` clean, and an LSP actually attaches to a real file.
- `sh clean.sh doctor` reports every link as `ok`.

## 5. Startup budget

```bash
for i in 1 2 3 4 5; do /usr/bin/time zsh -i -c exit; done
nvim --headless --startuptime /tmp/s.log -c qa && grep "NVIM STARTED" /tmp/s.log
```

Minimal tier must produce **zero** `command not found` output on a box with no
starship, fzf, or ripgrep.

## Pass criteria

- `./docker-test.sh test` exits 0 on Debian and Ubuntu.
- Tier matrix (§3) behaves per table, including idempotent re-runs.
- Backups are created for real files and restored by `clean.sh unlink` (§1.4).
- macOS smoke test (§4) passes before tagging.
