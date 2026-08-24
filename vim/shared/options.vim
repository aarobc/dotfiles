" Options that work in both vim and neovim. Sourced by vim/vimrc and, over in the
" neovim config, by nvim/init.lua -- so this is the one place they are written.
" Anything needing a plugin or an editor-only feature belongs in the caller.

"change the leader from backslash
let mapleader=","

" Create the 'vimrc' autocmd group, used by shared/autocmds.vim, and immediately
" clear it in case this file is being sourced a second time.
augroup vimrc | execute 'autocmd!' | augroup END

" NOTE: no `syntax on` here. It implies `filetype on`, which runs detection over
" buffers that already exist -- including the file named on the command line.
" Any FileType autocmd registered afterwards misses that buffer, so `nvim f.lua`
" would silently lose the tab settings in shared/autocmds.vim while `:e f.lua`
" kept them. Callers turn syntax on after sourcing shared/autocmds.vim; neovim
" needs no `syntax on` at all, it is on by default.

if (has("termguicolors"))
  set termguicolors
endif

set shell=/bin/zsh
set lazyredraw
set nowrap

set colorcolumn=90

set backspace=indent,eol,start

" to disable the global markers
" set shada="NONE"
" set tabstop=4
" set softtabstop=4
" set shiftwidth=4
set expandtab
set listchars=tab:→\ ,space:·,trail:▸,nbsp:+
set background=dark
set autoindent
" set smartindent

"generic folding settings
set foldmethod=syntax
set foldcolumn=1
let javaScript_fold=1
set foldnestmax=10      "allowed depth of sub-folds
set nofoldenable        "dont fold by default
set foldlevelstart=99   "needed for some reason to not fold everything
" set foldlevel=1         "this is just what i use

set mouse=r
set number
"set working directory to current file path
set autochdir

"---------------------------------[Search]----
set hlsearch
set incsearch
set smartcase
set ignorecase

set wildmenu

"window split settings
set splitbelow
set splitright

"allow vilual block cursor to go anywhere
set virtualedit=block

" Always show statusline
set laststatus=2

" check file change every 4 seconds ('CursorHold') and reload the buffer upon
" detecting change; the autocmd half lives in shared/autocmds.vim
set autoread

" vim-fugitive gdiff direction, and generally nicer diffs
set diffopt+=vertical

" workaround to deal with laggy response
if ! has('gui_running')
    set ttimeoutlen=10
    augroup FastEscape
        autocmd!
        au InsertEnter * set timeoutlen=0
        au InsertLeave * set timeoutlen=1000
    augroup END
endif
