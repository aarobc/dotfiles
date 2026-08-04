" ----------------------------------------------------------------------------
" Auto-install vim-plug if not present
" ----------------------------------------------------------------------------
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo ' . data_dir . '/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" ----------------------------------------------------------------------------
" Plugins
" ----------------------------------------------------------------------------
call plug#begin('~/.vim/plugged')

" The following are examples of different formats:
" Plug 'user/repo'
" Plug 'user/repo', { 'branch': 'main' }
" Plug 'user/repo', { 'for': 'php' }  " On-demand loading

Plug 'gregsexton/MatchTag'
Plug 'tomasr/molokai'
Plug 'scrooloose/nerdtree'
Plug 'Raimondi/delimitMate'
Plug 'wesQ3/vim-windowswap'
Plug 'vim-scripts/Tabmerge'

Plug 'bling/vim-airline'
Plug 'vim-airline/vim-airline-themes'

Plug 'christoomey/vim-tmux-navigator'
Plug 'kshenoy/vim-signature'
Plug 'unblevable/quick-scope'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-obsession'
Plug 'tommcdo/vim-fubitive'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'junegunn/vim-easy-align'

Plug 'wellle/targets.vim'
Plug 'lambdalisue/suda.vim'
Plug 'dense-analysis/ale'
Plug 'sheerun/vim-polyglot'
Plug 'tomtom/tcomment_vim'
Plug 'neoclide/jsonc.vim'
Plug 'chrisbra/Colorizer'
Plug 'lewis6991/gitsigns.nvim'

" Commented out / disabled plugins (preserved for reference)
" Plug 'pangloss/vim-javascript'
" Plug 'maxmellon/vim-jsx-pretty'
" Plug 'leafgarland/typescript-vim'
" Plug 'StanAngeloff/php.vim'
" Plug 'vim-scripts/phpfolding.vim'
" Plug 'docker/docker' , {'rtp': '/contrib/syntax/vim/'}
" Plug 'sirtaj/vim-openscad'
" Plug 'klen/python-mode'
" Plug 'tpope/vim-rhubarb'
" Plug 'nathanaelkane/vim-indent-guides'
" Plug 'othree/html5.vim'
" Plug 'nixprime/cpsm'
" Plug 'neoclide/coc.nvim'
" Plug 'fatih/vim-go'

call plug#end()
