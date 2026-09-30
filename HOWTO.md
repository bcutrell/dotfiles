# 0. optional — the stashes are the only local-only thing left.
#    --include-untracked keeps files stashed with -u; --binary keeps binary hunks.
#    (Plain `git stash show -p` silently drops both, and step 3 deletes the stashes.)
cd ~/dotfiles && git stash show -p --include-untracked --binary 'stash@{0}' > ~/stash0.patch
git stash show -p --include-untracked --binary 'stash@{1}' > ~/stash1.patch

# 1. remove the old stow symlinks
cd ~/dotfiles && sh clean.sh unlink        # answer n to the restore prompt

# 2. strays stow made that the new manifest doesn't own
rm -f ~/TMUX_GUIDE.md ~/.config/.stylua.toml

# 3. wipe and re-clone
cd ~ && rm -rf ~/dotfiles
git clone https://github.com/bcutrell/dotfiles.git ~/dotfiles
cd ~/dotfiles && sh setup.sh
