+++
title = "Moving Back to ZSH"
date = 2014-02-17
+++
After using bash for about a year now, I've decided to try [zsh](http://www.zsh.org/) again.
To do this, I began by opening up the [zsh page](https://wiki.archlinux.org/index.php/zsh) on the trusty Arch Linux wiki to use as a starting guide.

I installed zsh with `pacman -S zsh`, set my default shell to zsh from bash with `chsh -s $(which zsh)`, and ran `zsh` to ensure it worked.
I followed the configuration guide provided at the initial run of zsh, choosing mostly default settings.

I wanted to try powerline, so I decided to install the [powerline-shell](https://github.com/milkbikis/powerline-shell) by [milkbikis](https://github.com/milkbikis) so I could use it.

Powerline requires a patched font for Unicode symbols, and I like using terminus, so I performed the following steps to get the patched Terminus font (known as Terminess):

* Clone [powerline-fonts](https://github.com/Lokaltog/powerline-fonts)
* Copy `Terminus/` directory to `~/.fonts/`
* Run `fc-cache -vf ~/.fonts`
* Updated my `.Xresources` (may be your `.Xdefaults`) with `URxvt*font: xft:Terminess\ Powerline:pixelsize=12`
* Reloaded my X settings with `xrdb -merge ~/.Xdefaults`

In addition to my [base16-resources](https://github.com/chriskempson/base16-xresources) chalk rxvt colour scheme, I also had to define one for zsh, using [base16-shell](https://github.com/chriskempson/base16-shell).

I then migrated my `.bashrc` and other bash configuration files to their zsh counterparts.

I like using the `Home` and `End` keys to go to the first and last input columns, and I expect that to be the default behaviour in my shell.
Because I chose vim keybindings for my install (I am trying to slowly learn them), this was a bit of a conflict, so to remedy it I followed the zsh [key bindings](https://wiki.archlinux.org/index.php/zsh#Key_bindings) instructions on the Arch wiki.

In `.zshrc`, I added all of my bash aliases, and added the following line to startx on boot:
```
[[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] && exec startx
```

So far, this is the end result:
![Resulting ZSH powerline](/images/powerline-result.png).

I hope to further improve on it in the near future.
