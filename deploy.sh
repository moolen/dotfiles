#!/bin/bash
set -e
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
LINKS=".xbindkeysrc .xinitrc .Xresources .tmux.conf .zshrc .config/Code/User/keybindings.json .config/Code/User/settings.json"
CONF_DIRS=$(find .config -maxdepth 1 -mindepth 1 -not -name Code -type d)

echo "deploying dotfiles.."

function make_link {
    echo creating $1
    CONF_DIR=$(dirname $1)
    rm -rf $HOME/$1
    mkdir -p $HOME/$CONF_DIR
    ln -s $DIR/$1 ~/$1
}

[ -d ~/.ssh ] || mkdir ~/.ssh
[ -d ~/bin ] || mkdir ~/bin

yay -Sy $(cat pkglist) --noconfirm
ln -s /usr/bin/nvim ~/bin/vim

for item in $LINKS $CONF_DIRS; do
    make_link $item
done
