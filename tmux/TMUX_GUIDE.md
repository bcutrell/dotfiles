# tmux Quick Reference

Prefix key: `Ctrl+a`

---

## Sessions

| Key | Action |
|-----|--------|
| `tmux new -s name` | New named session |
| `tmux ls` | List sessions |
| `tmux attach -t name` | Attach to session |
| `prefix + d` | Detach |
| `prefix + $` | Rename session |
| `prefix + s` | Switch sessions (interactive) |

---

## Windows

| Key | Action |
|-----|--------|
| `prefix + c` | New window |
| `prefix + 1-9` | Switch to window by number |
| `prefix + n / p` | Next / previous window |
| `prefix + ,` | Rename window |
| `prefix + &` | Kill window |

Windows are numbered from 1 and auto-renumber when one is closed.

---

## Panes

| Key | Action |
|-----|--------|
| `prefix + \|` | Split horizontal (same dir) |
| `prefix + -` | Split vertical (same dir) |
| `Alt + Arrow` | Move between panes (no prefix) |
| `prefix + H/J/K/L` | Resize pane (repeatable) |
| `prefix + z` | Toggle pane zoom |
| `prefix + x` | Kill pane |
| `prefix + {` / `}` | Swap pane left/right |

---

## Copy Mode (vi)

| Key | Action |
|-----|--------|
| `prefix + [` | Enter copy mode |
| `v` | Begin selection |
| `C-v` | Toggle rectangle selection |
| `y` | Yank and exit |
| `q` | Exit copy mode |
| `/` | Search forward |
| `?` | Search backward |
| `g` / `G` | Top / bottom of history |

---

## Misc

| Key | Action |
|-----|--------|
| `prefix + r` | Reload config |
| `prefix + M` | Toggle mouse mode |
| `prefix + t` | Show clock |
| `prefix + ?` | List all keybindings |

---

## Workflow Tips

**Start a project session:**
```sh
tmux new -s myproject
```

**Typical layout:** one window per concern (editor, server, shell), panes for things you want to see at once.

**Zoom in on a pane** (`prefix + z`) when you need more screen space, zoom out to return.

**Search scrollback** with copy mode (`prefix + [` then `/`). History limit is 50,000 lines.

**Reattach after disconnect:**
```sh
tmux attach -t myproject
# or just: tmux a
```
