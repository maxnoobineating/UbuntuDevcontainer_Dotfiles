
" ############################# "
" suffix section

" setting combo key waiting time
" (vim don't have combination key, it only wait a while for the potential squence
" which led to a lot of keymapping causing laggy input)
" after notimeout, this is mainly for startify to not take too long to react to indexing
set timeoutlen=100
" XXX testing with notimeout, no reason to have dangling precursor key other than when it's a mistype, but mistype is often cancel by <Esc> (alt+any key), so the timeout is pretty irrelevant, and it causes problem with <leader><key> send out <key> if it's dangling, which isn't preferable in any way.
" XXX set compatible will mess up this setting, so put this in the end
set notimeout
call SetGlobalTimeoutSnapShot(v:false, 100)


" Set SignColumn background color to light gray
" 256 xterm color see: https://www.ditig.com/publications/256-colors-cheat-sheet
highlight SignColumn ctermbg=0
highlight CocMenuSel ctermfg=152 ctermbg=132
highlight CocFloating ctermfg=96 ctermbg=0
highlight Comment term=italic cterm=italic ctermfg=181 guifg=#80a0ff
highlight Cursor cterm=reverse ctermbg=12
highlight Visual term=reverse cterm=reverse ctermfg=132 ctermbg=123 guibg=DarkGrey
highlight VertSplit ctermfg=97 ctermbg=0 gui=reverse
highlight SpecialKey term=bold cterm=bold ctermfg=11 ctermbg=8 guifg=Cyan

" tabline hl group w/ airline tabline setting as well
highlight TabLineSel  term=underline,reverse cterm=underline,reverse ctermfg=131 ctermbg=53 gui=bold
highlight TabLine term=underline cterm=underline ctermfg=97 ctermbg=0 gui=underline guibg=DarkGrey
highlight TabLineFill term=underline cterm=underline ctermfg=97 ctermbg=0 gui=reverse
highlight link airline_tabline TabLine
highlight link airline_tabline_fill TabLineFill
highlight link airline_tabline_active TabLineSel
highlight link airline_tabline_inactive TabLine
highlight link airline_tabline_separator TabLine

augroup HITABFILL
    autocmd!
    autocmd User AirlineModeChanged highlight airline_warning ctermfg=232 ctermbg=167
    autocmd User AirlineModeChanged highlight airline_warning_bold ctermfg=232 ctermbg=167
    autocmd User AirlineModeChanged highlight airline_warning_inactive ctermfg=232 ctermbg=167
    autocmd User AirlineModeChanged highlight airline_warning_inactive_bold ctermfg=232 ctermbg=167
    " |AirlineAfterInit|    after plugin is initialized, but before the statusline is replaced
    " |AirlineAfterTheme|   after theme of the statusline has been changed
    " |AirlineToggledOn|    after airline is activated and replaced the statusline
    " |AirlineToggledOff|   after airline is deactivated and the statusline is restored to the original
    " |AirlineModeChanged|  The mode in Vim changed.
augroup END


" disable autocomment-out of newlines
" putting this at the end to avoid formatoptions resetting
autocmd BufRead,BufNewFile,FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o