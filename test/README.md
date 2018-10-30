# testbench

Create local mirror & server http
```
$ mkdir arch-mirror && cd $_
$ rsync -rtlvH --delete-after --delay-updates --safe-links rsync://mirror.23media.de/archlinux/ .
$ python3 -m http.server
```

Download archlinux iso and set up variables:
```
$ export ISO=~/Downloads/archlinux-2018.04.01-x86_64.iso
$ export PACMAN_MIRROR='http://192.168.178.21:8000/$repo/os/$arch'
```

Run remastering, boot VM
```
$ sudo -E ./run.sh
$ sudo virt-viewer arch-dotfiles-test
```
