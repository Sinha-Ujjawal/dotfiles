## dotfiles
Configuration files for tools I use.

- My [Vim](https://www.vim.org/) settings: [.vimrc](.vimrc). Recommend to use Vim >= 9
- My [Neovim](https://neovim.io/) settings: [.config/nvim/init.vim](.config/nvim/init.vim)
- My [TMUX](https://github.com/tmux/tmux/wiki) settings: [.tmux.conf](.tmux.conf)
- My [Aider](https://aider.chat/) settings: [.aider.conf.yml](.aider.conf.yml)
- My [i3wm](https://i3wm.org/) settings: [.config/i3/config](.config/i3/config) and [.config/i3blocks/config](.config/i3blocks/config)
- My [XDG Desktop Portal](https://wiki.archlinux.org/title/XDG_Desktop_Portal) settings: [.config/xdg-desktop-portal/portals.conf](.config/xdg-desktop-portal/portals.conf)

Note that both Vim and Neovim shares the same Vim plugins.

## Starter Config Files

Also, I have some started project config files

- Starter [Pyright](https://github.com/microsoft/pyright) Config file: [pyrightconfig.json](./pyrightconfig.json)
- Starter [Clang-format](https://clang.llvm.org/docs/ClangFormat.html) Config file: [.clang-format](./.clang-format)

## Getting Started

- Clone the repository with submodules loaded
```console
git clone --recurse-submodules https://github.com/Sinha-Ujjawal/dotfiles.git
```

- If the repo is already cloned, and you want to refresh the submodules
```console
git submodule update --init --recursive
```

- Run [setup.sh](./setup.sh) file to quickly setup on MacOS and Linux. Note that, I haven't tested this script on Windows or other OSs.
```console
yes | bash setup.sh
```

- [Optional] If using [i3wm](https://i3wm.org/) then install the dependencies listed in [.config/i3/config](.config/i3/config)

- [Optional] If using [XDG Desktop Portal](https://wiki.archlinux.org/title/XDG_Desktop_Portal) then also restart the service using `systemctl`
```console
# Install:
# sudo apt install xdg-desktop-portal xdg-desktop-portal-gtk
systemctl --user restart xdg-desktop-portal
systemctl --user restart xdg-desktop-portal-gtk
```
