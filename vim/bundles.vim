set nocompatible
filetype off
set rtp+=~/.vim/bundle/Vundle.vim/
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'
Plugin 'gregsexton/MatchTag'
Plugin 'tomasr/molokai'
Plugin 'scrooloose/nerdtree'
Plugin 'Raimondi/delimitMate'
Plugin 'wesQ3/vim-windowswap'
Plugin 'vim-scripts/Tabmerge'

" javascript
" Plugin 'pangloss/vim-javascript'
" Plugin 'maxmellon/vim-jsx-pretty'
" Plugin 'leafgarland/typescript-vim'

" php
" Plugin 'StanAngeloff/php.vim'
" Plugin 'vim-scripts/phpfolding.vim'

Plugin 'bling/vim-airline'
Plugin 'vim-airline/vim-airline-themes'

Plugin 'christoomey/vim-tmux-navigator'
" for marks
Plugin 'kshenoy/vim-signature'
" Plugin 'docker/docker' , {'rtp': '/contrib/syntax/vim/'}
" Plugin 'sirtaj/vim-openscad'
" Plugin 'klen/python-mode'
Plugin 'unblevable/quick-scope'     " xor Vundle
" git plugin
Plugin 'tpope/vim-fugitive'
Plugin 'tpope/vim-surround'
Plugin 'tpope/vim-repeat'
Plugin 'tpope/vim-obsession'
" Plugin 'nathanaelkane/vim-indent-guides'
Plugin 'ctrlpvim/ctrlp.vim'
" Plugin 'othree/html5.vim'
" Plugin 'nixprime/cpsm'
Plugin 'junegunn/vim-easy-align'

" allow motions on strings. is awesome
Plugin 'wellle/targets.vim'
Plugin 'lambdalisue/suda.vim'
" code inspection
Plugin 'dense-analysis/ale'
" Plugin 'neoclide/coc.nvim'
Plugin 'fatih/vim-go'

Plugin 'sheerun/vim-polyglot'
Plugin 'tomtom/tcomment_vim'
Plugin 'neoclide/jsonc.vim'
Plugin 'chrisbra/Colorizer'


call vundle#end()
