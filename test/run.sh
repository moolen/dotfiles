#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DEST_ISO="/var/lib/libvirt/images/archlinux-custom.iso"

if [ "$EUID" -ne 0 ]
    then echo "Please run as root"
    exit
fi

# build installer
$DIR/../backup/tools/build-installer

echo "starting http server for install script at :3000"
cd $DIR/../backup/
python3 -m http.server --directory $DIR/../backup/ 3000 &

# create iso
#$DIR/remaster.sh
#sudo mv arch-custom.iso $DEST_ISO

if [ ! -f "$ISO" ]; then
  echo "ISO not found: ${ISO}"
  exit 1
fi
sudo cp $ISO $DEST_ISO

NAME="arch-dotfiles-test"

sudo virsh destroy $NAME 2>&1 >/dev/null
sudo virsh undefine $NAME 2>&1 >/dev/null
sudo virsh vol-delete --pool default $NAME.qcow2 2>&1 >/dev/null

sudo virsh net-list --all
sudo virsh net-autostart default 2>&1 >/dev/null
sudo virsh net-start default 2>&1 >/dev/null

sudo virt-install \
    --name arch-dotfiles-test \
    --memory 512 \
    --cdrom "$DEST_ISO" \
    --disk pool=default,size=10 \
    --network=default \
    --noautoconsole \
    --events on_poweroff=preserve \
    --os-type=linux \
    --os-variant=generic
