" Mappings that work in both vim and neovim, with no plugin behind them.
" Keys whose implementation differs per editor (NERDTree vs netrw, telescope,
" the lua/ modules) are mapped by the caller instead -- see vim/vimrc and
" nvim/init.lua, which keep the same keys bound to the nearest equivalent.

"easier window navigation
nnoremap <silent> <Tab> :wincmd w<CR>
nnoremap <silent> <S-Tab> :wincmd W<CR>

" Space to toggle folds.
nnoremap <Space> za
vnoremap <Space> za

"jumping to beginning and end of lines
noremap B ^
noremap E $

"move between splits, on htns rather than hjkl
nnoremap <silent> <C-h> <C-w>h
nnoremap <silent> <C-t> <C-w>j
nnoremap <silent> <C-n> <C-w>k
nnoremap <silent> <C-s> <C-w>l
nnoremap <silent> <C-\> <C-w>p

"same, from inside a terminal buffer
if has('nvim') || has('terminal')
    tnoremap <Esc> <C-\><C-n>
    tnoremap <silent> <C-h> <C-\><C-n><C-w>h
    tnoremap <silent> <C-t> <C-\><C-n><C-w>j
    tnoremap <silent> <C-n> <C-\><C-n><C-w>k
    tnoremap <silent> <C-s> <C-\><C-n><C-w>l
endif

"moving splits around
nnoremap <C-w>S <C-w>L
nnoremap <C-w>T <C-w>J
nnoremap <C-w>N <C-w>K

"open file looking thing in new tab
"map gf :tabedit <cfile><CR>

" vim quickscope repurposing t to jump to second blue match
" noremap t 2f
" noremap T 2F
