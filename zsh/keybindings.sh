# ctrl+s: prepend sudo
function add_sudo() {
    BUFFER="sudo "$BUFFER
    zle end-of-line
}
zle -N add_sudo
bindkey "^s" add_sudo

# ctrl-k: kill-till-end-of-line
bindkey "^k" kill-line

# ctrl-q: kill current word
bindkey "^q" delete-word

# lock X
alias lock="xtrlock"

# kubernetes
alias k="kubectl"
alias ks="kubectl -n kube-system"

# git
alias g='git'
alias ga='git add'
alias gaa='git add --all'
alias gc='git commit -v'
alias gcm='git checkout master'
alias gcd='git checkout develop'
alias gco='git checkout'
alias gcp='git cherry-pick'
alias gd='git diff'
alias gf='git fetch'
alias gfa='git fetch --all --prune'
alias gfo='git fetch origin'
alias gm='git merge'
alias gp='git push'


# misc
alias diff='diff --color=auto'
alias grep='grep --color=auto'
alias c="clear"
alias l="ls -la"

tm () {
    SESSION=${1:-HACK}
    tmux has-session -t $SESSION
    if [ $? -eq 0 ]; then
        tmux attach -t $SESSION
        return
    fi
    tmux -2 new-session -d -s $SESSION
    tmux rename-window 'home'
    tmux new-window -t $SESSION:1 -n 'scratch'
    tmux select-window -t $SESSION:0
    tmux -2 attach-session -t $SESSION
}

# ssh tunnel
tnl () {
    if [ $# -ne "2" ]; then
        echo -e "usage: tnl [target-host] [target-port]\n"
        echo "Environment Variables:"
        echo -e "SSH_OPTS\tadditional arguments for ssh"
        return
    fi
    TARGET=$1
    PORT=$2
    echo "> forwarding $TARGET:$PORT to localhost:8000"
    ssh $SSH_OPTS -L 8000:127.0.0.1:$PORT $TARGET
}

# get fingerprint from remote
fingerprint (){
    if [ "$#" -lt "1" ]; then
        echo -e "usage: fingerprint [hostname] [..args]\n"
        echo -e "examples:\n"
        echo "$ fingerprint example.com"
        echo -e "> SHA1 Fingerprint=...\n"
        echo "$ fingerprint example.com -sha256"
        echo "> SHA256 Fingerprint=..."
        return
    fi
    HOST=$1
    shift
    echo | openssl s_client -connect "$HOST":443 |& openssl x509 -fingerprint "$@" -noout
}

# pull/push dotfiles to remote
cpdot (){
    set -x
    if [ $# -ne "2" ]; then
        echo "usage: cpdot [action] [ssh-target]"
        echo "  [action]"
        echo "    pull | pulls the dotfiles from the ssh-taget"
        echo "    push | pushs the dotfiles to the ssh-target"
        echo "  [ssh-target]"
        echo "    this will be passed directly to ssh/rsync"
        return
    fi
    ACTION=$1
    TARGET=$2
    case $ACTION in
        pull)
            echo "pulling from $TARGET"
            rsync -a $TARGET:dotfiles ~/dotfiles/
        ;;
        push)
            echo "pushing to $2"
            rsync -a ~/dotfiles/ $TARGET:dotfiles
        ;;
        *)
            echo "invalid action"
        ;;
    esac
}

function countdown(){
    date1=$((`date +%s` + $1));
    while [ "$date1" -ge `date +%s` ]; do
        echo -ne "$(date -u --date @$(($date1 - `date +%s`)) +%H:%M:%S)\r";
        sleep 0.1
    done
}

# execute arbitrary commands via ansible
function ax() {
    if [ $# -ne "3" ]; then
        echo "usage: ax [inventory] [hosts] [cmd]"
        echo "executes [cmd] on hosts from [inventory] matching [hosts]"
        return
    fi
    INVENTORY=$1
    HOSTS=$2
    CMD=$3
    ansible -i "$INVENTORY" -a "$CMD" "$HOSTS"
}

