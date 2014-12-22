
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
set term=screen-256color

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
"set working directory to current file
set autochdir

"easier window navigation
nnoremap <silent> <Tab> :wincmd w<CR>
nnoremap <silent> <S-Tab> :wincmd W<CR>
"map <C-h> <C-w>h
"map <C-j> <C-w>j
"map <C-k> <C-w>k
"map <C-l> <C-w>l

"should figuro out what's going on here...
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

"for windowswap plugin:
"should learn keyboard commands though
let g:windowswap_map_keys = 0 "prevent default bindings
nnoremap <silent> <leader>yw :call WindowSwap#MarkWindowSwap()<CR>
nnoremap <silent> <leader>pw :call WindowSwap#DoWindowSwap()<CR>
nnoremap <silent> <leader>ww :call WindowSwap#EasyWindowSwap()<CR>

"enable matchit plugin:
runtime macros/matchit.vim


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

fu! CustomFoldText()
    "get first non-blank line
    let fs = v:foldstart
    while getline(fs) =~ '^\s*$' | let fs = nextnonblank(fs + 1)
    endwhile
    if fs > v:foldend
        let line = getline(v:foldstart)
    else
        let line = substitute(getline(fs), '\t', repeat(' ', &tabstop), 'g')
    endif

    let w = winwidth(0) - &foldcolumn - (&number ? 8 : 0)
    let foldSize = 1 + v:foldend - v:foldstart
    let foldSizeStr = " " . foldSize . " lines "
    let foldLevelStr = repeat("+--", v:foldlevel)
    let lineCount = line("$")
    let foldPercentage = printf("[%.1f", (foldSize*1.0)/lineCount*100) . "%] "
    let expansionString = repeat(".", w - strwidth(foldSizeStr.line.foldLevelStr.foldPercentage))
    return line . expansionString . foldSizeStr . foldPercentage . foldLevelStr
endf

set foldtext=CustomFoldText()
"reference:
"tabm <number> moves tab to that location.
"example: tabm 0 moves tab to location 0 (first location)
"
"move existing window into new tab:
":tabedit %<CR>
