# dotfiles

Shell, git, tmux, vim and Neovim config for macOS and Debian/Ubuntu. Two POSIX
`sh` scripts, no dependencies, no stow.

## Setup

### New machine

```bash
git clone https://github.com/bcutrell/dotfiles.git ~/dotfiles
cd ~/dotfiles
sh setup.sh --full       # workstation: Neovim + LSP, Node, fzf, ripgrep, starship
sh setup.sh --minimal    # VM/server: git, curl, tmux, screen, plugin-free vim
exec $SHELL
```

On a full install, open `nvim` once: lazy.nvim installs plugins and Mason
installs the language servers. Then run `:checkhealth`. The first `vim` launch
installs its plugins too.

### Existing machine

```bash
cd ~/dotfiles && git pull
sh setup.sh --full       # or --minimal; installs anything missing, fixes links
exec $SHELL
```

Then bring editor plugins in line with the config:

- nvim: `:Lazy sync` (installs, updates and removes plugins)
- vim, full tier: `:PlugClean` then `:PlugUpdate`

The starship and fzf init caches rebuild on their own.

| Flag | Does |
|---|---|
| `--full`, `--minimal` | pick a tier; omit to be asked |
| `--link-only` | symlink only, install nothing |
| `--yes` | no prompts, every default |
| `--check` | report OS, tools and links; changes nothing |

Re-running is safe and switches tiers. Anything already at a target path is
moved to `~/.dotfiles_backup/<timestamp>/`. Git identity and the credential
helper are written to `~/.gitconfig.local`, which `.gitconfig` includes.

Setup leaves an already-installed Neovim alone; see [Neovim](#neovim) for the
version it needs.

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
`h` fuzzy-picks a history entry. The prompt shows directory, git branch/status and an
active Python venv; see `starship.toml` for why it stops there.

## Vim

`vim/base.vim` holds the settings both tiers share, including the built-in
`habamax` colorscheme; `vim-light/.vimrc` adds nothing. `vim/.vimrc` adds vim-plug, tokyonight,
fzf, NERDTree, ALE, fugitive and lightline (`,f`/`,t` files, `,b` buffers,
`,r` grep, `,d` tree). ALE lints on save and on leaving insert mode, not while typing.

## Neovim

Based on [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim) with
lazy.nvim, fzf-lua, harpoon, oil, diffview, csvview and vimwiki. Mason installs
`lua_ls`, `pyright`, `ts_ls`, `stylua` and `prettier` on first launch; `clangd`,
`gopls` and `rust_analyzer` are configured but installed on demand with
`:MasonInstall`. Set `vim.g.have_nerd_font = true` if a Nerd Font is installed.

Needs Neovim 0.11+, git, Node and ripgrep; the full tier installs them. To
upgrade an older Neovim: `brew upgrade neovim`, or on Linux remove it and re-run
setup.

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

## Colors

tmux, vim and nvim use truecolor (tokyonight) only when `COLORTERM` is
`truecolor` or `24bit`, which iTerm2, Ghostty, WezTerm and Alacritty set.
Otherwise vim and nvim fall back to the 256-color `habamax` (Terminal.app, most
ssh sessions). ssh does not forward
`COLORTERM`; to keep truecolor on a remote box, add `SendEnv COLORTERM` to
`~/.ssh/config` and `AcceptEnv COLORTERM` to the server's `sshd_config`.
Restart the tmux server (`tmux kill-server`) after changing terminals.

## Clipboard

Inside tmux, the tmux paste buffer is the shared clipboard for nvim, vim and
copy mode, and `set-clipboard on` forwards every copy via OSC 52 to the terminal
you are sitting at, through ssh if need be. Outside tmux, nvim and vim write
OSC 52 themselves over ssh and use the system clipboard locally. Vim pastes the
tmux buffer with `,p` / `,P`; nvim pastes with `p`.

The terminal must allow it. iTerm2: Settings > General > Selection >
"Applications in terminal may access clipboard". Terminal.app has no OSC 52.
