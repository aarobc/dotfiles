Intended for ach linux

- neovim
- zsh
- git
- make


Clone into home directory, then run:

```
make deps

make config
```

Upon changing defined paths or config files, modify the `install.conf.yaml` file and re-run
`make config`

## Vim Plugin Management

This setup uses **vim-plug**. To manage plugins:

1.  **Add a plugin**: Edit `vim/bundles.vim` and add `Plug 'user/repo'`.
2.  **Install**: Open Vim/Neovim and run `:PlugInstall`.
3.  **Update**: Run `:PlugUpdate`.
4.  **Remove**: Remove the line from `vim/bundles.vim` and run `:PlugClean`.

Plugins are automatically installed on the first run of Vim on a new system.
