
"------------------------------------------------------------------[Vundle]----
source ~/.vim/bundles.vim

"------------------------------------------------------------------[General]----

filetype plugin indent on     " required!


syntax on
"default vim background color for monokai theme:
let g:molokai_original=1
set t_Co=256″
colorscheme molokai
"attempt to fix weird background color issues
set term=screen-256color

set nowrap
"set nofoldenable

"disable auto commenting:
"autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

set backspace=indent,eol,start

set smartindent
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab

"set expandtab
"set autoindent

"set mouse=a
set number
"change the leader from backslash
let mapleader=","

"easier window navigation
nnoremap <silent> <Tab> :wincmd w<CR>
nnoremap <silent> <S-Tab> :wincmd W<CR>
"map <C-h> <C-w>h
"map <C-j> <C-w>j
"map <C-k> <C-w>k
"map <C-l> <C-w>l

function! s:WindowMappings()
    " Switch focus to adjacent window
    nnoremap <left> <c-w>h
    nnoremap <right> <c-w>s
    nnoremap <up> <c-w>n
    nnoremap <down> <c-w>t
    " Move active window
    nnoremap <s-left> <c-w>H
    nnoremap <s-right> <c-w>S
    nnoremap <s-up> <c-w>n
    nnoremap <s-down> <c-w>T
    " Discard unfocused windows
    " (disabled because it interferes with quickfix usage)
    "nnoremap <silent> <cr> :only<cr>
endfunction

"nerdTree
nnoremap <C-n> :NERDTree<CR>

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
"map gf :tabedit <cfile><CR>
noremap gf :exec "tabedit" substitute(expand("<cfile>"), '^\/\.\.', "..", "")<cr>

"commenter 
vmap <C-;> <leader>ci


"swap the layouts of horozontal and vertical
"noremap <C-w>h :windo wincmd H<CR>
"noremap <C-w>t :windo wincmd K<CR>

"merge tabs into single page
noremap <C-w>m :Tabmerge<CR>

"save file as root
cmap w!! w !sudo tee > /dev/null %
"------------------------ autoformatter plugin
autocmd FileType javascript noremap <buffer>  <c-f> :call JsBeautify()<cr>
" for html
autocmd FileType html noremap <buffer> <c-f> :call HtmlBeautify()<cr>
" for css or scss
autocmd FileType css noremap <buffer> <c-f> :call CSSBeautify()<cr>

"for windowswap plugin:
let g:windowswap_map_keys = 0 "prevent default bindings
nnoremap <silent> <leader>yw :call WindowSwap#MarkWindowSwap()<CR>
nnoremap <silent> <leader>pw :call WindowSwap#DoWindowSwap()<CR>
nnoremap <silent> <leader>ww :call WindowSwap#EasyWindowSwap()<CR>

"for php
"nnoremap <leader>= mzgg=G`z
"enable matchit plugin:
runtime macros/matchit.vim

"reference:
"tabm <number> moves tab to that location.
"example: tabm 0 moves tab to location 0 (first location)
"
"move existing window into new tab:
":tabedit %<CR>
