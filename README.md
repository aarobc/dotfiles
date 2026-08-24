Intended for Arch Linux

- neovim
- zsh
- git
- make


Clone into home directory, then run:

```
make deps

make configs
```

Upon changing defined paths or config files, modify the `install.conf.yaml` file and re-run
`make configs`

## Editor config

Neovim is the daily driver; plain vim is a backup for machines that lack it.

| Path  | Linked to        | Contents                                               |
| ----- | ---------------- | ------------------------------------------------------ |
| `nvim/` | `~/.config/nvim` | `init.lua`, the `lua/` modules, `langservers/`         |
| `vim/`  | `~/.config/vim`  | `vimrc` plus `shared/`, the editor-agnostic config     |

`vim/shared/` (options, mappings, autocmds, commands) is the single source of
truth: `vim/vimrc` sources it, and so does `nvim/init.lua`. Put settings and
keybindings there unless they need a plugin or one editor's features.

Keys backed by a plugin in neovim (`<C-f>`, `<C-p>`, `<C-b>`, `<leader>g`,
`<leader>f`) are rebound to builtin stand-ins in `vim/vimrc`, so the muscle
memory survives.

Note: vim only reads `~/.config/vim/vimrc` when neither `~/.vimrc` nor
`~/.vim/vimrc` exists (`:help xdg-vimrc`). `make configs` removes those if they
are symlinks.

## Neovim plugin management

Plugins are managed by the built-in `vim.pack` (nvim 0.12+); the list is in
`nvim/lua/plugins.lua` and missing ones are cloned on startup.

1.  **Add a plugin**: add `'user/repo'` to the list in `nvim/lua/plugins.lua`.
2.  **Update**: `:lua vim.pack.update()`, or `:lua vim.pack.update({'name'})` for one.
3.  **Remove**: drop the line, then `:lua vim.pack.del({'name'})`.
4.  **List**: `:lua = vim.pack.get()`.

Treesitter parsers are host-compiled, listed in `nvim/lua/ts_parsers.lua` and
installed by `make parsers`. Language servers run in containers built lazily by
`nvim/langservers/compose.yml`; see `nvim/lua/lsp.lua`.
