" Autocommands that work in both vim and neovim. All of them hang off the
" 'vimrc' group created in shared/options.vim, so re-sourcing is idempotent.

augroup vimrc
  autocmd BufRead,BufNewFile .env.* set filetype=sh

  "disable auto commenting:
  autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

  "syntax coloring for arduino
  au BufRead,BufNewFile *.ino set filetype=cpp
  "*.vue is detected as filetype=vue by nvim; it used to be forced to html here,
  "which blocked vue_ls

  " Fallback indent per filetype. A project's .editorconfig overrides these in
  " neovim -- its builtin support applies on BufReadPost, after FileType -- so
  " use one of those for anything that is not the default. Nothing here consults
  " eslint: the LSP client runs it diagnostics-only (nvim/lua/lsp.lua), so a
  " project whose eslint indent rule disagrees will squiggle, not reindent.
  " Plain vim has no .editorconfig support, so for it these are the last word.
  au FileType make            setlocal ts=2 sts=2 tw=2 noet
  au FileType lua             setlocal ts=2 sts=2 sw=2 noexpandtab
  au Filetype html            setlocal ts=2 sts=2 sw=2
  au Filetype vue             setlocal ts=2 sts=2 sw=2 expandtab
  au Filetype javascript      setlocal ts=2 sts=2 sw=2
  au Filetype javascriptreact setlocal ts=2 sts=2 sw=2 expandtab
  au Filetype php             setlocal ts=4 sts=4 sw=4
  au Filetype yaml            setlocal ts=2 sts=2 sw=2 expandtab
  au Filetype typescript      setlocal ts=2 sts=2 sw=2 expandtab
  au Filetype json            setlocal ts=2 sts=2 sw=2 expandtab

  au BufNewFile,BufRead Jenkinsfile setf groovy

  " see 'autoread' in shared/options.vim
  au CursorHold * checktime

  " shebang filetype detection for extensionless scripts
  autocmd BufRead,BufNewFile * if getline(1) =~ '^#!.*bun' | setfiletype javascript | endif

  "run syntax check on entire document
  " autocmd BufEnter * :syntax sync fromstart
augroup END
