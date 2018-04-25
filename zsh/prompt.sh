# Reference for colors: http://stackoverflow.com/questions/689765/how-can-i-change-the-color-of-my-prompt-in-zsh-different-from-normal-text
autoload -U colors && colors

setopt PROMPT_SUBST

set_prompt() {
    # •••
    PS1='%(?.%{$fg[green]%}•%{$reset_color%}%{$fg[yellow]%}•%{$reset_color%}%{$fg[red]%}•%{$reset_color%}.%{$fg[red]%}•%{$reset_color%}%{$fg[red]%}•%{$reset_color%}%{$fg[red]%}•%{$reset_color%}) '

    # Path: http://stevelosh.com/blog/2010/02/my-extravagant-zsh-prompt/
    PS1+="%{$fg_bold[blue]%}${PWD/#$HOME/~}%{$reset_color%}"

    # Git
    if git rev-parse --is-inside-work-tree 2> /dev/null | grep -q 'true' ; then
        PS1+=' ('
        PS1+="%{$fg[blue]%}$(git rev-parse --abbrev-ref HEAD 2> /dev/null)%{$reset_color%}"
        PS1+=") $MODE_INDICATOR"
    fi
    PS1+=" "
}

precmd_functions+=set_prompt
