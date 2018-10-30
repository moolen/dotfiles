#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# build installer
if [[ ! -f $DIR/../backup/arch-installer ]]; then
    $DIR/../backup/tools/build
fi

ISO=$(find /var/lib/libvirt/images -name 'archlinux-*.iso')
if [[ ! -f "$ISO" ]]; then
  echo "no 'archliinux-*.iso' file found in /var/lib/libvirt/images. aborting."
  exit 1
fi

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
    --cdrom "$ISO" \
    --disk pool=default,size=10 \
    --network=default \
    --noautoconsole \
    --events on_poweroff=preserve \
    --os-type=linux \
    --os-variant=generic

echo -e "\nclick 'boot archlinux' in VM. Then change password & start ssh:"
echo "(VM) $ passwd"
echo "(VM) $ systemctl start sshd"
echo -e "(VM) $ ip a \n"

echo "copy and run the installer, follow the instructions & reboot:"
echo "$ scp ../backup/arch-installer root@192.168.122.XX:/root"
echo "$ ssh root@192.168.122.16 -x \"DEVICE=/dev/sda DEVICE_CRYPT_PASS=1234 SWAP_SIZE=2G TIMEZONE=Europe/Berlin HOSTNAME=testbox ROOT_PASS=1234 MYUSERNAME=dawg MYUSERPASS=1234 /root/arch-installer\""
