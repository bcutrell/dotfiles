# dotfiles

Shell, git, tmux, vim and Neovim config for macOS and Debian/Ubuntu. Two POSIX
`sh` scripts, no dependencies, no stow.

## Setup

```bash
git clone https://github.com/bcutrell/dotfiles.git ~/dotfiles
cd ~/dotfiles
sh setup.sh --full       # workstation: Neovim + LSP, Node, fzf, ripgrep, starship
sh setup.sh --minimal    # VM/server: git, curl, tmux, screen, plugin-free vim
exec $SHELL
```

| Flag | Does |
|---|---|
| `--full`, `--minimal` | pick a tier; omit to be asked |
| `--link-only` | symlink only, install nothing |
| `--yes` | no prompts, every default |
| `--check` | report OS, tools and links; changes nothing |

Re-running is safe and switches tiers. Anything already at a target path is
moved to `~/.dotfiles_backup/<timestamp>/`. Git identity and the credential
helper are written to `~/.gitconfig.local`, which `.gitconfig` includes.

After a full install, run `nvim` once so lazy.nvim installs plugins, then
`:Mason` and `:checkhealth`. On macOS, Neovim must be 0.11+ for the current
plugin pins (`brew upgrade neovim`).

### Starting fresh

```bash
cd ~/dotfiles && sh clean.sh unlink   # remove links; answer n to the restore prompt
cd ~ && rm -rf ~/dotfiles
git clone https://github.com/bcutrell/dotfiles.git ~/dotfiles
cd ~/dotfiles && sh setup.sh --full
```

Old stow links are recognised by `unlink`. If the old checkout is already
gone, skip the first line.

### What gets linked

`manifest()` in `lib.sh` is the allowlist.

| Repo | Target | Tier |
|---|---|---|
| `shell/.zshrc`, `.bashrc`, `.aliases` | `~/` | both |
| `git/.gitconfig`, `.gitignore_global` | `~/` | both |
| `tmux/.tmux.conf` | `~/.tmux.conf` | both |
| `vim-light/.vimrc` | `~/.vimrc` | minimal |
| `vim/.vimrc` | `~/.vimrc` | full |
| `nvim/.config/nvim` | `~/.config/nvim` | full |
| `config/.config/starship.toml` | `~/.config/starship.toml` | full |

### Cleanup

```bash
sh clean.sh doctor    # same as setup.sh --check
sh clean.sh cache     # pip, npm, brew, go, nvim plugins/LSPs, shell init caches, old backups
sh clean.sh brew      # uninstall Homebrew/Linuxbrew, strip brew shellenv from rc files
sh clean.sh unlink    # remove symlinks, offer to restore the newest backup
sh clean.sh all       # cache, then unlink
```

### Testing

Linux is tested in Docker; macOS by hand.

```bash
./docker-test.sh build      # debian:12 and ubuntu:22.04 images
./docker-test.sh test       # syntax, minimal install, clean shell startup, unlink round-trip
./docker-test.sh test-full  # full install (slow)
./docker-test.sh test-nvim  # headless Neovim config load
./docker-test.sh cleanup
```

## Shells

`.zshrc` and `.bashrc` source `shell/.aliases`, which holds the shared
environment (PATH, EDITOR, LANG, fzf defaults) and aliases. Every optional tool
is guarded, so a bare box starts silently. starship and fzf init scripts are
cached under `~/.cache/{zsh,bash}` and regenerated when the binary changes.
`h` fuzzy-picks a history entry.

## Vim

`vim/base.vim` holds the settings both tiers share. `vim-light/.vimrc` adds
only the built-in `habamax` colorscheme. `vim/.vimrc` adds vim-plug, tokyonight,
fzf, NERDTree, CtrlP, ALE, fugitive and lightline (`,f` files, `,r` grep,
`,d` tree, `,t` CtrlP).

## Neovim

Based on [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim) with
lazy.nvim, fzf-lua, harpoon, oil, diffview, csvview and vimwiki. Mason installs
`lua_ls`, `pyright`, `ts_ls`, `stylua` and `prettier` on first launch; `clangd`,
`gopls` and `rust_analyzer` are configured but installed on demand with
`:MasonInstall`. Set `vim.g.have_nerd_font = true` if a Nerd Font is installed.

Needs Neovim 0.9+, git, a C compiler, Node, Python 3 and ripgrep.

## Tmux

Default `Ctrl-b` prefix, vi copy mode, windows numbered from 1, mouse off.

| Key | Does |
|---|---|
| `prefix \|` / `prefix -` | split right / below, same directory |
| `prefix c` | new window, same directory |
| `prefix H/J/K/L` | resize by 5, repeatable |
| `prefix m` | toggle mouse |
| `prefix r` | reload config |
| `prefix [` then `v`, `y` | select, copy |
| `prefix ]` | paste the tmux buffer |

## Clipboard

Inside tmux, the tmux paste buffer is the shared clipboard for nvim, vim and
copy mode, and `set-clipboard on` forwards every copy via OSC 52 to the terminal
you are sitting at, through ssh if need be. Outside tmux, nvim and vim write
OSC 52 themselves over ssh and use the system clipboard locally. Vim pastes the
tmux buffer with `,p` / `,P`; nvim pastes with `p`.

The terminal must allow it. iTerm2: Settings > General > Selection >
"Applications in terminal may access clipboard". Terminal.app has no OSC 52.
