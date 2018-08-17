#!/bin/bash
set -ex

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR

ISO=$DIR/archlinux.iso
ISO_MOUNT=$DIR/iso
CUSTOM_ISO=$DIR/arch-custom.iso
CUSTOM_MOUNT=$DIR/customiso

if [ ! -f $ISO ]; then
    echo "archlinux.iso does not exist. go get one!"
    exit
fi

# cleanup
sudo umount $ISO_MOUNT || true >/dev/null 2>&1
sudo umount $CUSTOM_MOUNT || true >/dev/null 2>&1
sudo rm -rf $ISO_MOUNT/*
rm $CUSTOM_ISO || true

# mount iso
sudo mount -t iso9660 -o loop $ISO $ISO_MOUNT
cp -a $ISO_MOUNT/* $DIR/tmp
sudo umount $ISO_MOUNT
mv tmp/* $ISO_MOUNT/

# expand squashfs
cd $ISO_MOUNT/arch/x86_64/
unsquashfs airootfs.sfs
cp ../boot/x86_64/vmlinuz squashfs-root/boot/vmlinuz-linux
cp $DIR/installer.sh squashfs-root/

# run installer
arch-chroot squashfs-root /installer.sh

rm airootfs.sfs
mv squashfs-root/boot/vmlinuz-linux $ISO_MOUNT/arch/boot/x86_64/vmlinuz
mv squashfs-root/boot/initramfs-linux.img $ISO_MOUNT/arch/boot/x86_64/archiso.img
rm squashfs-root/boot/initramfs-linux-fallback.img
mv squashfs-root/pkglist.txt $ISO_MOUNT/arch/pkglist.x86_64.txt
mksquashfs squashfs-root airootfs.sfs
rm -rf squashfs-root
md5sum airootfs.sfs > airootfs.md5

mkdir mnt
mkdir new
dd if=/dev/zero bs=1M count=150 of=efiboot-new.img
mkfs.fat -n "ARCHISO_EFI" efiboot-new.img
mount -t vfat -o loop efiboot-new.img new
mount -t vfat -o loop $ISO_MOUNT/EFI/archiso/efiboot.img mnt
cp -r mnt/* new/

cp $ISO_MOUNT/arch/boot/x86_64/vmlinuz new/EFI/archiso/vmlinuz.efi
cp $ISO_MOUNT/arch/boot/x86_64/archiso.img new/EFI/archiso/archiso.img
umount mnt
umount new
rm -rf mnt new
mv efiboot-new.img $ISO_MOUNT/EFI/archiso/efiboot.img


cd $ISO_MOUNT
LABEL=$(grep -r -oE "archisolabel=(.+)\s" arch/boot/syslinux  | cut -d = -f 2)
genisoimage -l -r -J -V "$LABEL" -b isolinux/isolinux.bin -no-emul-boot -boot-load-size 4 -boot-info-table -c isolinux/boot.cat -o $CUSTOM_ISO ./

sudo mount -t iso9660 -o loop $CUSTOM_ISO $CUSTOM_MOUNT

cd $DIR/docker
docker build -t prov .
docker rm -f prov

docker run  \
    --name prov \
    --cap-add NET_ADMIN \
    -d \
    -v $DIR/config/dnsmasq.conf:/etc/dnsmasq.conf:Z \
    -v $CUSTOM_MOUNT:/mnt/archiso \
    prov
