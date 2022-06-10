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

" php
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
Plugin 'ctrlpvim/ctrlp.vim'
Plugin 'junegunn/vim-easy-align'

" allow motions on strings. is awesome
Plugin 'wellle/targets.vim'
" when editing file as root workaround
Plugin 'lambdalisue/suda.vim'

" code inspection
Plugin 'dense-analysis/ale'
Plugin 'sheerun/vim-polyglot'
Plugin 'tomtom/tcomment_vim'

call vundle#end()
