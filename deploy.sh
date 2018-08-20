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

LINKS=".xbindkeysrc .xinitrc .Xresources .tmux.conf .zshrc .config/rofi .config/nvim .config/awesome .config/termite .config/sway .config/i3blocks"

for item in $LINKS; do
    make_link $item
done

