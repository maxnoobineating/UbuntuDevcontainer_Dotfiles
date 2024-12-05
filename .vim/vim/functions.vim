"=============================================================================="
" Functions
" open tab with command, if already exists in tabs, switch to it
function! TabDropCMD(cmd)
  execute "tab" . a:cmd
  
endfunction

" vim performance profiling:
" the second time toggle will save and close the file
" find the file at /tmp/vim_profile.log
" use zsh command listVimProfile to see the list
let g:vimprofilepaused = -1
" Set up an autocommand to stop profiling when exiting a file
autocmd VimLeavePre * if g:vimprofilepaused == 1 | let g:vimprofilepaused = -1 | noautocmd wqall! | endif
autocmd VimLeavePre * if g:vimprofilepaused == 0 | let g:vimprofilepaused = -1 | profile pause | noautocmd wqall! | endif
" updatetime is defaulted to 4000 ms, and CursorHold is triggered if no key input in updatetime
set updatetime=4000
" Set up an autocommand to pause profiling after 4 seconds of inactivity
autocmd CursorHold * if g:vimprofilepaused == 0 | echo 'profiling paused!' | profile pause | let g:vimprofilepaused = 1 | endif
function! ProfilingToggle()
    if g:vimprofilepaused == -1
        let g:vimprofilepaused = 0
        execute 'profile start /tmp/vim_profile.log'
        execute 'profile func *'
        execute 'profile file *'
    elseif g:vimprofilepaused == 1
        let g:vimprofilepaused = 0
        execute 'profile continue'
    else
        let g:vimprofilepaused = 1
        execute 'profile pause'
    endif
endfunction
" --------------------------------------------------------------------------------


" alternative to map search hk: <\m>
"function! s:ShowMaps()
"    let old_reg = getreg("a")          " save the current content of register a
"    let old_reg_type = getregtype("a") " save the type of the register as well
"    try
"        redir @a                           " redirect output to register a
"        " Get the list of all key mappings silently, satisfy "Press ENTER to continue"
"        silent map | call feedkeys("\<CR>")
"        redir END                          " end output redirection
"        vnew                               " new buffer in vertical window
"        put a                              " put content of register
"        setlocal buftype=nofile bufhidden=delete " set delete buffer after exiting
"        " Sort on 4th character column which is the key(s)
"        %!sort -k1.4,1.4
"        setlocal nowrap
"        setlocal nomodifiable
"    finally                              " Execute even if exception is raised
"        call setreg("a", old_reg, old_reg_type) " restore register a
"    "trying to replace :q in the mapping pane with :bd | q for clearing buffer
"    endtry
"endfunction
"com! ShowMaps call s:ShowMaps()      " Enable :ShowMaps to call the function
" nnoremap <Leader>m :ShowMaps<CR>

" --------------------------------------------------------------------------------
" --------------------------------------------------------------------------------
" failure command when pattern matched for recursive macro fail condition
" use: `:QLineCheck PATTERN` inside recording to stop the macro when pattern
" is matched.

function! s:QLstop(pattern)
	echo a:pattern
  let l:current_line = getline('.')
  if match(l:current_line, a:pattern) != -1
		echoerr "End Of Recursive Macro"
  endif
endfunction
command! -nargs=1 QLstop call s:QLstop(<f-args>)

" function! _test()
"   let l:current_line = getline('.')
" 	if match(l:current_line, 'END') != -1
" 		echoerr "End Of Recursive Macro"
"   endif
" endfunction