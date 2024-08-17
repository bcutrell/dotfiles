# README

## Table of Contents

1. [Stow](#stow)
2. [Vim](#vim)
3. [Neovim](#neovim)
4. [Ripgrep](#ripgrep)
5. [Fonts](#fonts)
6. [Shells](#shells)
7. [Snippets](#snippets)
8. [Neovim HotKeys](#neovim-hotkeys)

## Stow

### Installation

- Mac: `brew install stow`
- Debian: `sudo apt-get install stow`

### Usage

- `stow <packagename>`: activates symlink
- `stow -n <packagename>`: trial runs or simulates symlink generation. Effective for checking for errors
- `stow -D <packagename>`: delete stowed package
- `stow -R <packagename>`: restows package
- `stow bash git nvim`: install packages

## Vim

- [amix/vimrc](https://github.com/amix/vimrc)

## Neovim

- [nvim-lua/kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim)

### Installation

- Mac: `brew install nvim`
- Debian: [Installation Instructions](#debian-neovim-installation)

#### Debian Neovim Installation

```shell
sudo apt-get install neovim

# or

nvim --version | head -n 1
wget https://github.com/neovim/neovim/releases/download/v0.9.1/nvim.appimage
chmod u+x nvim.appimage && ./nvim.appimage
./nvim.appimage --appimage-extract
./squashfs-root/usr/bin/nvim

# optional
ln -s /usr/bin/nvim /usr/bin/vim
cp ./squashfs-root/usr/bin/nvim usr/bin/nvim
```

## Ripgrep

- [Installation Instructions](https://github.com/BurntSushi/ripgrep#installation)

## Fonts

- [JetBrains Mono](https://www.jetbrains.com/lp/mono/): optional, provides various icons
- [Nerd Font](https://www.nerdfonts.com/): More options

## Shells

In order of preference:

1. [ohmyz.sh](https://ohmyz.sh/#install)
2. bash-it: `git clone --depth=1 https://github.com/Bash-it/bash-it.git ~/.bash_it && ~/.bash_it/install.sh`
3. fish: `brew install fish`

## Snippets

```shell
# Change shell
# per session
$ exec zsh -l  # switch to zsh
$ exec bash -l # switch to bash

# per login
$ chsh -s $(which bash)
$ chsh -s $(which zsh)

# list shells
$ cat /etc/shells
```

# Kickstart.nvim Key Mappings

## Basic Keymaps
| Key Combination     | Mode    | Command                                      | Description                           |
|---------------------|---------|----------------------------------------------|---------------------------------------|
| `<Esc>`             | Normal  | `<cmd>nohlsearch<CR>`                        | Clear search highlights               |
| `[d`                | Normal  | `vim.diagnostic.goto_prev`                   | Go to previous diagnostic message     |
| `]d`                | Normal  | `vim.diagnostic.goto_next`                   | Go to next diagnostic message         |
| `<leader>e`         | Normal  | `vim.diagnostic.open_float`                  | Show diagnostic error messages        |
| `<leader>q`         | Normal  | `vim.diagnostic.setloclist`                  | Open diagnostic quickfix list         |
| `<Esc><Esc>`        | Terminal| `<C-\\><C-n>`                                | Exit terminal mode                    |
| `<C-h>`             | Normal  | `<C-w><C-h>`                                 | Move focus to the left window         |
| `<C-l>`             | Normal  | `<C-w><C-l>`                                 | Move focus to the right window        |
| `<C-j>`             | Normal  | `<C-w><C-j>`                                 | Move focus to the lower window        |
| `<C-k>`             | Normal  | `<C-w><C-k>`                                 | Move focus to the upper window        |

## Telescope Keymaps
| Key Combination     | Mode    | Command                                      | Description                           |
|---------------------|---------|----------------------------------------------|---------------------------------------|
| `<leader>sh`        | Normal  | `builtin.help_tags`                          | Search help                           |
| `<leader>sk`        | Normal  | `builtin.keymaps`                            | Search keymaps                        |
| `<leader>sf`        | Normal  | `builtin.find_files`                         | Search files                          |
| `<leader>ss`        | Normal  | `builtin.builtin`                            | Search select Telescope               |
| `<leader>sw`        | Normal  | `builtin.grep_string`                        | Search current word                   |
| `<leader>sg`        | Normal  | `builtin.live_grep`                          | Search by grep                        |
| `<leader>sd`        | Normal  | `builtin.diagnostics`                        | Search diagnostics                    |
| `<leader>sr`        | Normal  | `builtin.resume`                             | Search resume                         |
| `<leader>s.`        | Normal  | `builtin.oldfiles`                           | Search recent files                   |
| `<leader><leader>`  | Normal  | `builtin.buffers`                            | Find existing buffers                 |
| `<leader>/`         | Normal  | `builtin.current_buffer_fuzzy_find`          | Fuzzily search in current buffer      |
| `<leader>s/`        | Normal  | `builtin.live_grep { grep_open_files = true, prompt_title = 'Live Grep in Open Files' }` | Search in open files  |
| `<leader>sn`        | Normal  | `builtin.find_files { cwd = vim.fn.stdpath 'config' }` | Search Neovim files       |

## LSP Keymaps
| Key Combination     | Mode    | Command                                      | Description                           |
|---------------------|---------|----------------------------------------------|---------------------------------------|
| `gd`                | Normal  | `require('telescope.builtin').lsp_definitions` | Go to definition                      |
| `gr`                | Normal  | `require('telescope.builtin').lsp_references` | Go to references                      |
| `gI`                | Normal  | `require('telescope.builtin').lsp_implementations` | Go to implementation               |
| `<leader>D`         | Normal  | `require('telescope.builtin').lsp_type_definitions` | Type definition                    |
| `<leader>ds`        | Normal  | `require('telescope.builtin').lsp_document_symbols` | Document symbols                   |
| `<leader>ws`        | Normal  | `require('telescope.builtin').lsp_dynamic_workspace_symbols` | Workspace symbols           |
| `<leader>rn`        | Normal  | `vim.lsp.buf.rename`                          | Rename                                |
| `<leader>ca`        | Normal  | `vim.lsp.buf.code_action`                     | Code action                           |
| `K`                 | Normal  | `vim.lsp.buf.hover`                           | Hover documentation                   |
| `gD`                | Normal  | `vim.lsp.buf.declaration`                     | Go to declaration                     |
| `<leader>th`        | Normal  | `vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())` | Toggle inlay hints        |

## Formatting Keymaps
| Key Combination     | Mode    | Command                                      | Description                           |
|---------------------|---------|----------------------------------------------|---------------------------------------|
| `<leader>f`         | Normal  | `require('conform').format { async = true, lsp_fallback = true }` | Format buffer               |
