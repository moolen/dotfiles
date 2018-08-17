#!/bin/bash

echo "installing arch.."

pacman-key --init
pacman-key --populate archlinux
pacman -Syu --noconfirm git

cat << EOF > /root/.bashrc
if [ ! -f /root/.init.ok ]; then
  export TIMEZONE=Europe/Berlin

  echo "specify hostname"
  read HOSTNAME

  echo "specify DEVICE_CRYPT_PASS"
  read DEVICE_CRYPT_PASS

  echo "specify SWAP_SIZE"
  read SWAP_SIZE

  echo "specify ROOT_PASS"
  read ROOT_PASS

  # username & password
  echo "specify username"
  read MYUSERNAME

  echo "specify user password"
  read MYUSERPASS

  echo "specify device to install archlinux"
  read DEVICE

  git clone https://github.com/moolen/dotfiles.git /root/dotfiles
  mkdir -p /root/dotfiles/backup/hosts/$HOST/
  touch /root/dotfiles/backup/hosts/$HOST/passwd

  /root/dotfiles/backup/installer.sh
  touch /root/.init.ok
fi
EOF

echo "done ;)"
