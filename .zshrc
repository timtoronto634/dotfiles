# ~/.zshrc

# load custom configs
source ~/.config/zsh/aliases.zsh
source ~/.config/zsh/functions.zsh

# fzf key bindings and fuzzy completion
command -v fzf >/dev/null && source <(fzf --zsh)
