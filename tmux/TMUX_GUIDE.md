# tmux

Everything below reflects `tmux/.tmux.conf` in this repo. No plugins, no TPM.

**Prefix is `Ctrl+b`** (tmux default). The `Ctrl+a` override is commented out at
the top of the config — uncomment those four lines if you prefer it.

Windows and panes are numbered from **1**, not 0, and renumber when one closes.

## Sessions

| Command | Does |
|---|---|
| `tmux` | Start an unnamed session |
| `tmux new -s work` | Start a session named `work` |
| `tmux ls` | List sessions |
| `tmux a -t work` | Attach to `work` |
| `prefix d` | Detach (session keeps running) |
| `prefix $` | Rename session |

Detaching is the whole point on a remote box: your work survives an SSH drop.

## Windows

| Key | Does |
|---|---|
| `prefix c` | New window **in the current pane's directory** |
| `prefix ,` | Rename window |
| `prefix n` / `prefix p` | Next / previous window |
| `prefix 1`…`9` | Jump to window by number |
| `prefix w` | Interactive window list |
| `prefix &` | Kill window |

## Panes

| Key | Does |
|---|---|
| `prefix \|` | Split left/right, same directory |
| `prefix -` | Split top/bottom, same directory |
| `prefix` + arrow | Move between panes |
| `prefix H/J/K/L` | Resize by 5, repeatable (hold the key) |
| `prefix z` | Zoom pane fullscreen / restore |
| `prefix x` | Kill pane |
| `prefix {` / `prefix }` | Swap pane left / right |

`%` and `"` are unbound on purpose — use `|` and `-`, which are mnemonic and
open in the current directory.

## Copy mode (vi keys)

| Key | Does |
|---|---|
| `prefix [` | Enter copy mode |
| `v` | Start selection |
| `C-v` | Toggle rectangle (block) selection |
| `y` | Copy selection and exit |
| `q` or `Escape` | Exit copy mode |
| `/` and `?` | Search forward / backward |
| `prefix ]` | Paste |

`v` and `y` are rebound here: tmux's own vi defaults are `Space` to select and
`Enter` to copy, and it binds `v` to rectangle-toggle.

Scrollback is 50,000 lines.

## Clipboard

`set-clipboard on` means a copy goes to the clipboard of the terminal you are
sitting at, via OSC 52 -- including over SSH. tmux both forwards the sequence
from programs running inside it (Neovim, vim) and emits it for its own
copy-mode yanks. The tmux default, `external`, only does the forwarding.

Your terminal has to allow it; in iTerm2 that is Settings > General >
Selection > "Applications in terminal may access clipboard". See the Clipboard
section of the top-level README.

## Mouse

Off by default. `prefix m` toggles it and reports the new state. Turn it on for
scrolling and pane resizing by drag; turn it off to get normal terminal
text selection back.

## Other

| Key | Does |
|---|---|
| `prefix r` | Reload `~/.tmux.conf` |
| `prefix ?` | List every binding |
| `prefix t` | Big clock |

## Notes

`default-terminal` is `tmux-256color`. If tmux fails to start with
"missing or unsuitable terminal" on an older macOS, that terminfo entry is
absent from the system ncurses — install a newer ncurses or fall back to
`screen-256color`.

Truecolor is forced on for `xterm*`, alacritty, and wezterm. If your terminal
reports something else and colors look flat, add it to the
`terminal-overrides` line.
