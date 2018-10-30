#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

MNT=/mnt/archiso
TMP_DIR=/mnt/customiso

if [[ ! -f "${ISO}" ]]; then
    echo "image does not exist: $ISO"
    exit 1
fi

umount $MNT 2>&1 >/dev/null
rm -rf $TMP_DIR 2>&1 >/dev/null
rm $DIR/arch-custom.iso 2>&1 >/dev/null

mkdir $MNT 2>&1 >/dev/null
mkdir $TMP_DIR 2>&1 >/dev/null

set -e
mount -t iso9660 -o loop $ISO $MNT
cp -a $MNT/* $TMP_DIR
cd $TMP_DIR/arch/x86_64

unsquashfs airootfs.sfs

# copy installer
cp $DIR/../backup/arch-installer $TMP_DIR/arch/x86_64/squashfs-root/root
# set root password
arch-chroot $TMP_DIR/arch/x86_64/squashfs-root /bin/bash -c "echo 'root:1234' | chpasswd"
# enable ssh
arch-chroot $TMP_DIR/arch/x86_64/squashfs-root /bin/bash -c "systemctl enable sshd"

# use custom mirror
if [[ "${PACMAN_MIRROR}" != "" ]]; then
    echo "Server = ${PACMAN_MIRROR}" > $TMP_DIR/arch/x86_64/squashfs-root/etc/pacman.d/mirrorlist
fi

# auto-execute installer
cat <<EOF > $TMP_DIR/arch/x86_64/squashfs-root/root/.zshrc
if [[ ! -f /root/arch-install.ok ]]; then
    export NONINTERACTIVE=1
    export DEVICE=/dev/sda
    export DEVICE_CRYPT_PASS=1234
    export SWAP_SIZE=2G
    export TIMEZONE=Europe/Berlin
    export HOSTNAME=testbox
    export ROOT_PASS=1234
    export MYUSERNAME=dawg
    export MYUSERPASS=1234
    /root/arch-installer | tee /root/arch-installer.log 2>&1
    touch /root/arch-install.ok
fi
EOF

# squash rootfs
cd $TMP_DIR/arch/x86_64
rm airootfs.sfs
mksquashfs squashfs-root airootfs.sfs
rm -r squashfs-root
md5sum airootfs.sfs > airootfs.md5

# add timeout for default boot option
echo "TIMEOUT 50" > /tmp/foo
cat $TMP_DIR/arch/boot/syslinux/archiso_head.cfg >> /tmp/foo
cat /tmp/foo > $TMP_DIR/arch/boot/syslinux/archiso_head.cfg
rm /tmp/foo

cd $TMP_DIR

# !important
# The ISO label must remain the same as the original label for the image to boot successfully
LABEL=$(strings $ISO | grep ARCH_ | head -1 | tr -d '[:space:]')
genisoimage -l -r -J -V $LABEL -b isolinux/isolinux.bin -no-emul-boot -boot-load-size 4 -boot-info-table -c isolinux/boot.cat -o $DIR/arch-custom.iso ./

umount $MNT
rm -rf $TMP_DIR
