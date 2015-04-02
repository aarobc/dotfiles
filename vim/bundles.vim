set nocompatible
filetype off
set rtp+=~/.vim/bundle/Vundle.vim/
"call vundle#rc()
call vundle#begin()


Plugin 'gmarik/vundle'
Plugin 'gregsexton/MatchTag'
Plugin 'tomasr/molokai'
Plugin 'tomtom/tcomment_vim'
Plugin 'scrooloose/nerdtree'
Plugin 'scrooloose/syntastic'
Plugin 'Raimondi/delimitMate'
Plugin 'wesQ3/vim-windowswap'
Plugin 'vim-scripts/Tabmerge'
Plugin 'pangloss/vim-javascript'
"Plugin 'jelera/vim-javascript-syntax'
Plugin 'StanAngeloff/php.vim'
Plugin 'vim-scripts/phpfolding.vim'
Plugin 'powerline/powerline', {'rtp': 'powerline/bindings/vim/'}
" Plugin 'joeytwiddle/sexy_scroller.vim'
Plugin 'christoomey/vim-tmux-navigator'
"Plugin 'Valloric/YouCompleteMe'
" for marks
Plugin 'kshenoy/vim-signature'
Plugin 'docker/docker' , {'rtp': '/contrib/syntax/vim/'}

call vundle#end()  

