# BACKUP

I've implemented a simple backup script that:

- creates a tarball from important files and directories
- encrypt the tarbar using gpg
- upload the encrypted tarball to gdrive

Apart from that i've created a archlinux installer that bootstraps the complete system for me. This is used to do the initial setup of a box. It'll install my day-to-day packages and deploy this dotfiles.

## SETUP

The backup script needs environment variables:
``` sh
$ cat << EOF >> ~/.localrc

# Which directories or files should be saved?
export BACKUP_DIRS="~/foo ~/bar ~/baz"

# The backup is encrypted using PGP. This recipient is used
BACKUP_GPG_RECIPIENT=MY-GPG-KEY-ID

# this is where the system state is stored
# use gdrive to query:
# > gdrive list -q "name contains 'my-backup-folder'"
BACKUP_GDRIVE_DIR_ID=id-of-gdrive-directory
EOF

```

## CREATE A BACKUP

Theres many things ppl want to backup. For me, i got all the important parts either in git repositories or hosted online (documents, pictures, music). That's why i don't really need to have filesystem-based snapshot mechanism to store the fs state.

What i do is simple: grab some files and directories; tar+encrypt them; put them somewhere safe.

``` sh
# backup important files
$ ./tools/backup
```

## ARCH INSTALLER

You can create a archlinux-installer which is a self-extracting archive that contains my dotfiles. In a nutshell the installer will:

- partition and format the disks using cryptsetup
- bootstrap the root filesystem
- setup timezone, locale and language
- set root password
- add user account
- install bootloader

Build the installer as follows. This creates a self-extracting executable `arch-installer`:

``` sh
$ ./tools/build-installer
```


You can do the installation in a non-interactive mode by specifying all necessary environment variables:

```
# prepare env vars
$ export NONINTERACTIVE=1
$ export DEVICE=/dev/sda
$ export DEVICE_CRYPT_PASS=1234
$ export SWAP_SIZE=2G
$ export TIMEZONE=Europe/Berlin
$ export HOSTNAME=testbox
$ export ROOT_PASS=1234
$ export MYUSERNAME=dawg
$ export MYUSERPASS=1234

# launch installer
$ ./arch-installer

```

Testing the installer

See [../test](../test) directory for instructions on testing.
