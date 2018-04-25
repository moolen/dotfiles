if [[ ! "$PATH" == *$HOME/dotfiles/fzf/bin* ]]; then
    export PATH="$PATH:$HOME/dotfiles/fzf/bin"
fi

[[ $- == *i* ]] && source "$HOME/dotfiles/fzf/shell/completion.zsh" 2> /dev/null

source "$HOME/dotfiles/fzf/shell/key-bindings.zsh"

