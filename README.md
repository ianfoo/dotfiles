# Ian's dotfiles

These dotfiles are organized into category directories. Because of this, the
files will not be in their appropriate location if this repository is cloned
directly to a home directory. This repository is intended to be [used in
conjunction with GNU
stow](http://brandon.invergo.net/news/2012-05-26-using-gnu-stow-to-manage-your-dotfiles.html).

[GNU stow](https://www.gnu.org/software/stow/) can be installed on macOS with
```bash
brew install stow
```

Stow creates links in its parent directories by default, so if, for example, you
wanted zsh configuration in your home directory, you could clone this repository
to a subdirectory of your home directory (e.g., `.dotfiles`) and do the following:

```
cd ~/.dotfiles
stow zsh
```

Use `stow *` to make all configuration available in the home directory.

