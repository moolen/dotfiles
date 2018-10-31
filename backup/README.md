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

# if you have existing state just pull it in
$ ./tools/state pull
```

### Host state / bootstrap credentials
I store sensitive information (user / password etc.) in a shell file. I source this file during the installation routine.

Create a credential file:

``` sh
mkdir -p ~/dotfiles/backup/hosts/myhostname
cat << EOF  > ~/dotfiles/backup/hosts/myhostname/passwd
#!/bin/bash

# luks/cryptsetup password
DEVICE_CRYPT_PASS=1234

# timezone setting
TIMEZONE=Europe/Berlin

# hostname
HOSTNAME=example

# configure swap partition size
SWAP_SIZE=4G

# root password
ROOT_PASS=mypass

# username & password
MYUSERNAME=iamtheuser
MYUSERPASS=12345
EOF
```

These credentials can also be backed up to google drive use `./tools/state` to manage it:

``` sh
# encrypt files
$ ./tools/state encrypt

# push credentials to gdrive
$ ./tools/state decrypt
```

## CREATE A BACKUP

Theres many things ppl want to backup. For me, i got all the important parts either in git repositories or hosted online (documents, pictures, music). That's why i don't really need to have filesystem-based snapshot mechanism to store the fs state.

What i do is simple: grab some files and directories; tar+encrypt them; put the msomewhere safe.

``` sh
# backup important files
$ ./tools/backup

# encrypt & push files to gdrie
$ ./tools/state encrypt
$ ./tools/state push
```

You can setup a hook: you just need a script file in your `$PATH` that can do something with that gpg file, e.g. copy it over to a offline location.
Supported hooks:
- `backup_archive_hook`
- `backup_state_hook`

Example hook file at `~/bin/backup_archive_hook`:
``` sh
#!/bin/bash

ARCHIVE=$1
echo found gpg archive at $ARCHIVE

scp $ARCHIVE $MY_REMOTE:/backup
```

## ARCH INSTALLER

You can create a archlinux-installer which is a self-extracting archive that contains my dotfiles. In a nutshell the installer will:

- partition and format the disks using cryptsetup
- bootstrap the root filesystem
- setup timezone, locale and language
- set root password
- add user account
- install bootloader

``` sh
$ ./tools/state encrypt
$ ./tools/build

# copy the installer over to naked machine
$ scp ~/dotfiles/backup/arch-installer $MYNEWMACHINE
```

On `$MYNEWMACHINE` just execute the installer and follow the instructions
``` sh
$ ./arch-installer
```

Alternatively you can do the installation in a non-interactive mode:

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
