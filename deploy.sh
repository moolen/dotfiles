#!/bin/bash
set -e
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "deploying dotfiles.."

function make_link {
    echo creating $1
    CONF_DIR=$(dirname $1)
    rm -rf $HOME/$1
    mkdir -p $HOME/$CONF_DIR
    ln -s $DIR/$1 ~/$1
}

LINKS=".xbindkeysrc .xinitrc .Xresources .tmux.conf .zshrc"

for item in $LINKS; do
    make_link $item
done

for confdir in $(find .config -maxdepth 1 -mindepth 1 -type d); do
    make_link $confdir
done

