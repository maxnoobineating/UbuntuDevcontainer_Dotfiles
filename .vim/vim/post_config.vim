
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
set ttimeout
set ttimeoutlen=20
call SetGlobalTimeoutSnapShot(v:false, 100)
" disable autocomment-out of newlines
" putting this at the end to avoid formatoptions resetting
autocmd BufRead,BufNewFile,FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o