
"------------------------------------------------------------------[Vundle]----
source ~/.vim/bundles.vim

"------------------------------------------------------------------[General]----
" Create the 'vimrc' autocmd group, used below, and immediately clear it in
" case this file is being sourced a second time.
augroup vimrc | execute 'autocmd!' | augroup END

filetype plugin indent on     " required!
    
syntax on
"default vim background color for monokai theme:
let g:molokai_original=1
set t_Co=256
colorscheme molokai
"attempt to fix weird background color issues
"shouldn't need to mess with this because tmux alias yay
"set term=screen-256color
"set term=xterm-256color

set nowrap

"javascript folding
function! s:JavascriptFileType()

    "set nofoldenable
    set foldlevelstart=0
    " fold methods available: syntax indent marker
    set foldmethod=indent
    set foldignore=
    set foldnestmax=1


    " "Refocus" folds
    nnoremap ,z zMzvzz

    " Make zO recursively open whatever top level fold we're in, no matter where the
    " cursor happens to be.
    nnoremap zO zCzO

endfunction
autocmd vimrc FileType javascript call s:JavascriptFileType()

" Space to toggle folds.
nnoremap <Space> za
vnoremap <Space> za


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
"set working directory to current file path
set autochdir

"easier window navigation
nnoremap <silent> <Tab> :wincmd w<CR>
nnoremap <silent> <S-Tab> :wincmd W<CR>


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

"au BufRead,BufNewFile *.txt set filetype=js

"open file looking thing in new tab
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

"for windowswap plugin:
"should learn keyboard commands though
let g:windowswap_map_keys = 0 "prevent default bindings
nnoremap <silent> <leader>yw :call WindowSwap#MarkWindowSwap()<CR>
nnoremap <silent> <leader>pw :call WindowSwap#DoWindowSwap()<CR>
nnoremap <silent> <leader>ww :call WindowSwap#EasyWindowSwap()<CR>



"enable matchit plugin:
runtime macros/matchit.vim

"vim-javascript syntax plugin highlighting enable
let g:javascript_enable_domhtmlcss = 1
"map <F5> <Esc>:EnableFastPHPFolds<Cr>
"map <F6> <Esc>:EnablePHPFolds<Cr>
"map <F7> <Esc>:DisablePHPFolds<Cr>
"to prevent annoying behavior of the folding plugin
let g:DisableAutoPHPFolding = 1

function! PhpSyntaxOverride()
    "folding stuff
    let php_folding=0
    setlocal foldmethod=manual
    EnableFastPHPFolds
    "syntax stuff
    hi! def link phpDocTags  phpDefine
    hi! def link phpDocParam phpType
endfunction

augroup phpSyntaxOverride
    autocmd!
    autocmd FileType php call PhpSyntaxOverride()
augroup END

"powerline stuffs:
" Always show statusline
set laststatus=2

"endfunction
"sexy scrolling settings:
"let g:SexyScroller_ScrollTime = 10
"let g:SexyScroller_MaxTime = 500
let g:SexyScroller_CursorTime = 0
let g:SexyScroller_EasingStyle = 2
"where
" - 1 = start fast, finish slowly            (like 2 but less so)
" - 2 = start very fast, finish very slowly  (recommended, default)
" - 3 = start slowly, get faster, end slowly (sexy)
" - 4 = start very slowly, end very slowly   (like 3 but more so)
"  - ? = constant speed                       (dull)

"do better auto complete brace behavior:
let delimitMate_expand_cr = 1
"let delimitMate_jump_expansion = 0
let delimitMate_expand_space = 1
" look into this:
"https://github.com/chrisbra/vim_dotfiles/blob/master/plugin/CustomFoldText.vim

"reference:
"tabm <number> moves tab to that location.
"example: tabm 0 moves tab to location 0 (first location)
"
"move existing window into new tab:
":tabedit %<CR>
