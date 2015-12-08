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
"run syntax check on entire document
autocmd BufEnter * :syntax sync fromstart
" colorscheme Tomorrow
"attempt to fix weird background color issues
"shouldn't need to mess with this because tmux alias yay
"set term=screen-256color
"set term=xterm-256color

set lazyredraw
set nowrap

"disable auto commenting:
autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

set backspace=indent,eol,start

" set smartindent
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab
set background=dark
set autoindent
filetype plugin indent on
"generic folding settings
set foldmethod=indent   "fold based on indent
set foldnestmax=1      "deepest fold is 10 levels
set nofoldenable        "dont fold by default
set foldlevel=1         "this is just what i use

set mouse=r
set number
"change the leader from backslash
let mapleader=","
"set working directory to current file path
set autochdir

"when pasting into vim:
set pastetoggle=<F10>

"---------------------------------[Search]----
set hlsearch
set incsearch
set smartcase
set ignorecase

set wildmenu

"window split settings
set splitbelow
set splitright

"powerline/airline stuffs:
" Always show statusline
set laststatus=2
let g:airline_powerline_fonts = 1
" let g:airline_theme='powerlineish'
let g:airline_theme='murmur'
" let g:airline_theme='molokai'
" let g:airline_theme='luna'
" Enable the list of buffers
" let g:airline#extensions#tabline#enabled = 1
" " Show just the filename
" let g:airline#extensions#tabline#fnamemod = ':t'

" workaround to deal with laggy response
if ! has('gui_running')
    set ttimeoutlen=10
    augroup FastEscape
        autocmd!
        au InsertEnter * set timeoutlen=0
        au InsertLeave * set timeoutlen=1000
    augroup END
endif

"easier window navigation
nnoremap <silent> <Tab> :wincmd w<CR>
nnoremap <silent> <S-Tab> :wincmd W<CR>

" Space to toggle folds.
nnoremap <Space> za
vnoremap <Space> za

"jumping to beginning and end of lines
noremap B ^
noremap E $

" vim quickscope repurposing t to jump to second blue match
noremap t 2f
noremap T 2F

"open file looking thing in new tab
"map gf :tabedit <cfile><CR>
noremap gf :exec "tabedit" substitute(expand("<cfile>"), '^\/\.\.', "..", "")<cr>
"syntax coloring for arduino
au BufRead,BufNewFile *.ino set filetype=cpp
au BufRead,BufNewFile *.vue set filetype=html

"save file as root
cmap w!! w !sudo tee > /dev/null %

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


autocmd Filetype html setlocal ts=2 sts=2 sw=2
autocmd Filetype javascript setlocal ts=4 sts=4 sw=4



" deal with drag issues when in tmux
" set mouse+=a
if &term =~ '^screen'
    " tmux knows the extended mouse mode
    set ttymouse=xterm2
endif

"nerdTree
nnoremap <C-f> :NERDTree<CR>



"swap the layouts of horozontal and vertical
"noremap <C-w>h :windo wincmd H<CR>
"noremap <C-w>t :windo wincmd K<CR>

"merge tabs into single page
noremap <C-w>m :Tabmerge<CR>

"ctrlP
let g:ctrlp_match_func = {'match': 'cpsm#CtrlPMatch'}
let g:ctrlp_max_files=0
noremap <C-B> :CtrlPBuffer<CR>
let g:ctrlp_prompt_mappings = {
    \ 'PrtSelectMove("j")':   ['<c-t>', '<down>'],
    \ 'PrtSelectMove("k")':   ['<c-n>', '<up>'],
    \ 'AcceptSelection("t")': ['<c-y>'],
    \ 'CreateNewFile()':      ['<c-f>'],
    \ 'ToggleType(1)':        ['<c-u>', '<c-up>'],
    \ 'PrtClear()':           ['<c-g>'],
    \ 'PrtHistory(-1)':       ['<c-b>'],
    \ 'ToggleType(-1)':       ['<c-down>'],
    \ 'PrtExit()':            ['<esc>', '<c-c>'],
    \ }

" silver searcher is supposed to be faster, but I'm not find that to be the case
if executable('ag')
  " let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'
  " let g:ctrlp_use_caching = 0
  " set grepprg=ag\ --nogroup\ --nocolor
  " let g:ackprg = 'ag --nogroup --nocolor --column'
endif
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
    " EnableFastPHPFolds
    EnablePHPFolds
    normal zR
    "syntax stuff
    hi! def link phpDocTags  phpDefine
    hi! def link phpDocParam phpType
endfunction

augroup phpSyntaxOverride
    autocmd!
    autocmd FileType php call PhpSyntaxOverride()
augroup END

" check file change every 4 seconds ('CursorHold') and reload the buffer upon detecting change
set autoread
au CursorHold * checktime

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


"move between splits:
nnoremap <C-H> <C-W><C-H>
nnoremap <C-T> <C-W><C-J>
nnoremap <C-N> <C-W><C-K>
nnoremap <C-S> <C-W><C-L>

"neovim stuff; move between terminal splits
if has('nvim')
    tnoremap <Esc> <C-\><C-n>
    tnoremap <C-h> <C-\><C-n><C-w>h
    tnoremap <C-t> <C-\><C-n><C-w>j
    tnoremap <C-n> <C-\><C-n><C-w>k
    tnoremap <C-s> <C-\><C-n><C-w>l

    nnoremap <C-h> <C-w>h
    nnoremap <C-t> <C-w>j
    nnoremap <C-n> <C-w>k
    nnoremap <C-s> <C-w>l
endif

"moving splits around
nnoremap <C-w>S <C-w>L
nnoremap <C-w>T <C-w>J
nnoremap <C-w>N <C-w>K

function! ToggleMouse()
    " check if mouse is enabled
    if &mouse == 'a'
        " disable mouse
        set mouse=
    else
        " enable mouse everywhere
        set mouse=a
    endif
endfunc

"reference:
"tabm <number> moves tab to that location.
"example: tabm 0 moves tab to location 0 (first location)
"
"let @a = ':s/row\['\(\w*\)'\]/row->\1/g'
" :s/row\['\(\w*\)'\]/row->\1/g
"move existing window into new tab:
":tabedit %<CR>
