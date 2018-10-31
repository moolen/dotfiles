# Testbench

## what is it doing?

Archiso has some "shortcomings" in regards to automation, in particular:

* a user has to manually click 'boot archlinux'. there's no way to automatically boot into the live-os root shell
* there is no way to launch a installation script automatically
* cloud-init (or derivatives) is not supported

To circumvent that it's necessary to remaster archiso and:

* add a timeout to the syslinux bootloader
* add our own `arch-installer` script and auto-launch it
* (optional) add our own package mirror

See [remaster.sh](./remaster.sh) for details.

DO NOT DISTRIBUTE THIS ISO. IT MAY HARM.

## Usage

#### (optional) create local arch package mirror
```
$ mkdir arch-mirror && cd $_
$ rsync -rtlvH --delete-after --delay-updates --safe-links rsync://mirror.23media.de/archlinux/ .
$ python3 -m http.server
```

#### download archlinux iso and set up variables:
```
$ export ISO=~/Downloads/archlinux-2018.04.01-x86_64.iso
$ (optional) export PACMAN_MIRROR='http://192.168.178.21:8000/$repo/os/$arch'
```

#### boot VM
```
$ sudo -E ./run.sh
$ sudo virt-viewer arch-dotfiles-test
```
