# DOTFILES

## Screenshots

![Clean](https://imgur.com/AoX81wa.png)
![Tiling](https://imgur.com/uwvasDt.png)

## INSTALL

```
$ git clone --recurse-submodules git@gitlab.com:Moritz.Johner/dotfiles.git ~/dotfiles

$ cd dotfiles

$ ./deploy.sh
```

## LOCAL RC

`~/.localrc` contains environment variables that are specific to a system.
These ones are picked up by my dotfiles:

``` sh
# ~/.localrc

MY_GITHUB_ACCESS_KEY=xxxx-yyyyy-zz

```

## BACKUP

See [backup](./backup) directory.
