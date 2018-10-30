#!/bin/bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DOTFILES=$DIR/..
echo "starting installer.."

if [ -f $DIR/hosts/$HOST/passwd ]; then
  echo decrypting host state
  TMP=$(mktemp)
  openssl aes-256-cbc -d -in $DIR/hosts/$HOST/passwd -out $TMP
  source $TMP
fi

PACKAGES=${PACKAGES:-$(cat $DIR/pkglist)}

function main {
  ping -c 1 8.8.8.8 || error "could not ping 8.8.8.8; no working internet connection?!"
  if [ -z "${DEVICE}" ]; then
    get_user_input
  fi

  echo DEVICE :: $DEVICE
  echo SWAP_SIZE :: $SWAP_SIZE
  echo TIMEZONE :: $TIMEZONE
  echo USER :: $MYUSERNAME
  echo HOSTNAME :: $HOSTNAME
  echo PACKAGES :: $PACKAGES
  echo -e "\npress enter to proceed with installation"
  read
  case $1 in
    "system")
        bootstrap_system
        ;;
    "os")
        bootstrap_os
        ;;
    "dotfiles")
        install_dotfiles
        ;;
    *)
        bootstrap_system
        bootstrap_os
        install_dotfiles
        ;;
  esac
}

function error {
    echo $1
    exit 1
}

function get_user_input {
    echo available devices:
    lsblk
    echo -e "\nplease specify the install device (full path!):"
    read DEVICE
    echo -e "\nplease specify the crypt pass:"
    read DEVICE_CRYPT_PASS
    echo -e "\nplease specify the swap file size:"
    read SWAP_SIZE
    echo -e "\nplease specify the timezone:"
    read TIMEZONE
    echo -e "\nplease specify the HOSTNAME:"
    read HOSTNAME
    echo -e "\nplease specify the root password:"
    read ROOT_PASS
    echo -e "\nplease specify the username:"
    read MYUSERNAME
    echo -e "\nplease specify $MYUSERNAME's password:"
    read MYUSERPASS
}

function chroot {
    arch-chroot /mnt /bin/bash -c "$1"
}

function bootstrap_system {
    # prepare partitions
    sgdisk -Z ${DEVICE}
    parted ${DEVICE} mklabel gpt
    sgdisk ${DEVICE} -n=1:0:+31M -t=1:ef02
    sgdisk ${DEVICE} -n=2:0:+512M
    sgdisk ${DEVICE} -n=3:0:0
    sgdisk -p ${DEVICE}
    partprobe ${DEVICE}

    mkfs.fat ${DEVICE}2

    echo -n ${DEVICE_CRYPT_PASS} | cryptsetup -c aes-xts-plain64 -y --use-random luksFormat ${DEVICE}3 -
    echo -n ${DEVICE_CRYPT_PASS} | cryptsetup luksOpen ${DEVICE}3 luks -

    # create encrypted partitions
    pvcreate /dev/mapper/luks
    vgcreate vg0 /dev/mapper/luks
    lvcreate --size ${SWAP_SIZE} vg0 --name swap
    lvcreate -l +100%FREE vg0 --name root

    # fs on devicemapper
    mkfs.ext4 -F /dev/mapper/vg0-root
    mkswap /dev/mapper/vg0-swap

    # mount
    mount /dev/mapper/vg0-root /mnt
    swapon /dev/mapper/vg0-swap
    mkdir /mnt/boot
    mount ${DEVICE}2 /mnt/boot

    pacstrap /mnt base base-devel grub zsh vim neovim git dialog wpa_supplicant

    genfstab -pU /mnt >> /mnt/etc/fstab

    echo "tmpfs /tmp tmpfs defaults,noatime,mode=1777 0 0" > /mnt/etc/fstab
}

function bootstrap_os {
    DEVNAME=$(basename $DEVICE)
    cat << EOF > /mnt/opt/installer.sh
    #!/bin/bash
    set -e

    [ -f /etc/localtime  ] && rm /etc/localtime
    ln -s /usr/share/zoneinfo/${TIMEZONE} /etc/localtime
    hwclock --systohc --utc
    echo ${HOST} > /etc/hostname

    echo LANG=en_US.UTF-8 >> /etc/locale.conf
    echo LANGUAGE=en_US >> /etc/locale.conf
    echo LC_ALL=C >> /etc/locale.conf
    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
    locale-gen

    echo root:${ROOT_PASS} | chpasswd

    useradd -m -g users -G wheel -s /bin/zsh ${MYUSERNAME}
    echo ${MYUSERNAME}:${MYUSERPASS} | chpasswd
    chown -R ${MYUSERNAME}: /home/${MYUSERNAME}

    # encryption / lvm booting support
    sed -i 's/MODULES=()/MODULES=(ext4)/g' /etc/mkinitcpio.conf
    sed -i 's/HOOKS=(base udev autodetect modconf block filesystems keyboard fsck)/HOOKS=(base udev autodetect modconf block encrypt lvm2 filesystems keyboard fsck)/g' /etc/mkinitcpio.conf
    mkinitcpio -p linux

    grub-install --target=i386-pc --recheck ${DEVICE}
    sed -i 's/GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="cryptdevice=\/dev\/${DEVNAME}3:luks:allow-discards"/g' /etc/default/grub
    grub-mkconfig -o /boot/grub/grub.cfg

    sed -i '/%wheel ALL=(ALL) ALL/s/^#//' /etc/sudoers

    # we need the this to be able to use sudo without tty
    echo 'Defaults !requiretty, !tty_tickets, !umask' >> /etc/sudoers
    echo 'Defaults visiblepw, path_info, insults, lecture=always' >> /etc/sudoers
    echo 'Defaults loglinelen=0, logfile =/var/log/sudo.log, log_year, log_host, syslog=auth' >> /etc/sudoers
    echo 'Defaults passwd_tries=3, passwd_timeout=1' >> /etc/sudoers
    echo 'Defaults env_reset, always_set_home, set_home, set_logname' >> /etc/sudoers
    echo 'Defaults !env_editor, editor="/usr/bin/vim:/usr/bin/vi:/usr/bin/nano"' >> /etc/sudoers
    echo 'Defaults timestamp_timeout=15' >> /etc/sudoers
    echo 'Defaults passprompt="[sudo] password for %u: "' >> /etc/sudoers
    echo 'Defaults lecture=never' >> /etc/sudoers
EOF

    chmod +x /mnt/opt/installer.sh
    chroot /opt/installer.sh
}

function install_dotfiles {
    cat << EOF > /mnt/opt/pkg_installer.sh
    chown -R ${MYUSERNAME}: /home/${MYUSERNAME}
    chmod 755 /var
    chmod -R 755 /var/lib

    su - ${MYUSERNAME} -c "
      echo \"${MYUSERPASS}\n\" | sudo -S -v
      if ! which yaourt; then
          git clone https://aur.archlinux.org/package-query.git /tmp/package-query
          git clone https://aur.archlinux.org/yaourt.git /tmp/yaourt
          cd /tmp/package-query
          makepkg -csi --noconfirm
          cd /tmp/yaourt
          makepkg -csi --noconfirm
          rm -rf /tmp/package-query /tmp/yaourt
      fi
      # thunderbird-enigmail
      gpg --recv-keys DB1187B9DD5F693B
      pacman -Sy archlinux-keyring --noconfirm
      yaourt -Sy ${PACKAGES} --noconfirm
      mkdir .ssh
      cd ~/dotfiles;
      ./deploy.sh
      mkdir ~/bin
      ln -s /usr/bin/nvim ~/bin/vim
    "

EOF

    chmod +x /mnt/opt/pkg_installer.sh
    mkdir /mnt/home/${MYUSERNAME}/dotfiles || true
    cp -r $DOTFILES /mnt/home/${MYUSERNAME}/dotfiles
    chroot /opt/pkg_installer.sh
}

main "$@"
