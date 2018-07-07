# Vars
HISTFILE=~/.zsh_history
SAVEHIST=10000 
setopt inc_append_history
setopt share_history

# Settings
export VISUAL=vim
export EDITOR=vim
export TERM=xterm-256color
export LANG=en_US.UTF-8
export PATH=~/bin:$PATH

# man colors
man() {
    LESS_TERMCAP_md=$'\e[01;31m' \
    LESS_TERMCAP_me=$'\e[0m' \
    LESS_TERMCAP_se=$'\e[0m' \
    LESS_TERMCAP_so=$'\e[01;44;33m' \
    LESS_TERMCAP_ue=$'\e[0m' \
    LESS_TERMCAP_us=$'\e[01;32m' \
    command man "$@"
}

# less colors
export LESS='-R'

if [ -f ~/.localrc ]; then
    source ~/.localrc
fi

# ssh agent
if [ ! -e ~/.ssh/agentsock ]; then
    eval $(ssh-agent -a ~/.ssh/agentsock)
else
    export SSH_AUTH_SOCK=~/.ssh/agentsock
fi

# plugins
source ~/dotfiles/zsh/plugins/fixls.zsh
autoload -Uz compinit && compinit -i

source ~/dotfiles/zsh/plugins/oh-my-zsh/lib/history.zsh
source ~/dotfiles/zsh/plugins/oh-my-zsh/lib/key-bindings.zsh
source ~/dotfiles/zsh/plugins/oh-my-zsh/lib/completion.zsh
source ~/dotfiles/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/dotfiles/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source ~/dotfiles/zsh/plugins/golang/golang.zsh
source ~/dotfiles/zsh/keybindings.sh

source ~/dotfiles/zsh/fzf.zsh
source ~/dotfiles/zsh/prompt.sh
