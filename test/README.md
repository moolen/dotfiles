# Testbench

download archlinux iso and set up variables:
```
$ export ISO=~/Downloads/archlinux-2018.04.01-x86_64.iso
```

(optional) create local arch package mirror
```
$ mkdir arch-mirror && cd $_
$ rsync -rtlvH --delete-after --delay-updates --safe-links rsync://mirror.23media.de/archlinux/ .
$ python3 -m http.server
```

boot VM
```
$ sudo -E ./run.sh
$ sudo virt-viewer arch-dotfiles-test
```

Once you see the bootscreen, specify the following kernel commandline arguments (press tab in menu and append):
```
# the latter is optional
script=http://192.167.178.21:3000/arch-installer pacman_mirror=http://192.167.178.21:8000
```
