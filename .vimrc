
"------------------------------------------------------------------[Vundle]----
source ~/.vim/bundles.vim

"------------------------------------------------------------------[General]----

filetype plugin indent on     " required!


syntax on
"default vim background color for monokai theme:
let g:molokai_original=1
set t_Co=256″
colorscheme molokai

set nowrap
"set nofoldenable

"disable auto commenting:
"autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

set backspace=indent,eol,start
set tabstop=2
set softtabstop=2
set shiftwidth=2
set expandtab
set autoindent

"set mouse=a
set number
"change the leader from backslash
let mapleader=","

"easier window navigation
nnoremap <silent> <Tab> :wincmd w<CR>
nnoremap <silent> <S-Tab> :wincmd W<CR>
map <C-h> <C-w>h
map <C-j> <C-w>j
map <C-k> <C-w>k
map <C-l> <C-w>l


"when pasting into vim:
set pastetoggle=<F10>

"---------------------------------[Search]----
set hlsearch
set incsearch
set smartcase
set ignorecase

set wildmenu

"syntax coloring for arduino
au BufRead,BufNewFile *.ino set filetype=cpp

"open file looking thing in new vim
map gf :tabedit <cfile><CR>

"commenter 
vmap <C-;> <leader>ci

"save file as root
cmap w!! w !sudo tee > /dev/null %
"------------------------ autoformatter plugin
autocmd FileType javascript noremap <buffer>  <c-f> :call JsBeautify()<cr>
" for html
autocmd FileType html noremap <buffer> <c-f> :call HtmlBeautify()<cr>
" for css or scss
autocmd FileType css noremap <buffer> <c-f> :call CSSBeautify()<cr>

"for php
"nnoremap <leader>= mzgg=G`z

