+++
title = "Setting Up Vim"
date = 2014-02-18
+++
After completing my initial [zsh setup](/blog/moving-back-to-zsh), I've decided to finally begin what I've been putting off - setting up vim.

## Color Scheme

Being entirely unexperienced with vim, I've decided to start with the simplest task possible, setting up my color scheme - base16 chalk.

### Vundle

After reading the instructions on the base16-vim repository, I decided to install [Vundle](https://github.com/gmarik/Vundle.vim) for package control support.
Vundle installation was simple and I simply followed the setups outlined in the Vundle [README](https://github.com/gmarik/Vundle.vim/blob/master/README.md).

### base16-chalk

With Vundle, installing base16-chalk was as easy as editing `~/.vimrc` to include:

```vim
Bundle 'chriskempson/base16-vim'

set background=dark
let base16colorspace=256  " Access colors present in 256 colorspace
colorscheme base16-chalk
```


### Syntax Highlighting

I wanted all of my files to automatically have their syntax highlighted, so I put this line in my `~/.vimrc`:
```
syntax on
```

So far these are all of the modifications I've performed to vim. Time to begin using it.
