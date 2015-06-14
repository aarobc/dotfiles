
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
" colorscheme Tomorrow
"attempt to fix weird background color issues
"shouldn't need to mess with this because tmux alias yay
"set term=screen-256color
"set term=xterm-256color

set nowrap

"generic folding settings
set foldmethod=indent   "fold based on indent
set foldnestmax=1      "deepest fold is 10 levels
set nofoldenable        "dont fold by default
set foldlevel=1         "this is just what i use

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
set fo-=o
"autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

set backspace=indent,eol,start

set smartindent
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab
"set expandtab
"set autoindent

autocmd Filetype html setlocal ts=2 sts=2 sw=2
autocmd Filetype javascript setlocal ts=4 sts=4 sw=4

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
nnoremap <C-f> :NERDTree<CR>


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
"vmap <C-;> <leader>ci


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

"window split settings
set splitbelow
set splitright

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

"syntastic:
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
"reference:
"tabm <number> moves tab to that location.
"example: tabm 0 moves tab to location 0 (first location)
"
"let @a = ':s/row\['\(\w*\)'\]/row->\1/g'
" :s/row\['\(\w*\)'\]/row->\1/g
"move existing window into new tab:
":tabedit %<CR>

" This function returns the highlight group used by git-gutter depending on how the line was edited (added/modified/deleted)
" It must be placed in the vimrc (or in any file that is sourced by vim)
" function! SignatureGitGutter(lnum)
"   let gg_line_state = filter(copy(gitgutter#diff#process_hunks(gitgutter#hunk#hunks())), 'v:val[0] == a:lnum')
"   "echo gg_line_state
"  
"   if len(gg_line_state) == 0
"     return 'Exception'
"   endif
"  
"   if gg_line_state[0][1] =~ 'added'
"     return 'GitGutterAdd'
"   elseif gg_line_state[0][1] =~ 'modified'
"     return 'GitGutterChange'
"   elseif gg_line_state[0][1] =~ 'removed'
"     return 'GitGutterDelete'
"   endif
" endfunction
"  
" " Next, assign it to g:SignatureMarkTextHL
" let g:SignatureMarkTextHL = 'SignatureGitGutter(l:lnum)'
 
" Now everytime Signature wants to place a sign, it calls this function and thus, we can dynamically assign a Highlight group g:SignatureMarkTextHL
" The advantage of doing it this way is that this decouples Signature from git-gutter. Both can remain unaware of the other.
