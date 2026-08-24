" Commands and functions that work in both vim and neovim.

com! ToJson %s/\(\w*\):/"\1"/

com! FormatJSON %!python -m json.tool

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
