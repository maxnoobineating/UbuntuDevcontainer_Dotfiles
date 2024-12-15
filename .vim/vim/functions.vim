"=============================================================================="
" Functions

" function! CloseBuffersType(type)
"     for buf in range(1, bufnr('$'))
"         if getbufvar(buf, '&filetype') ==# a:type
"             execute 'bwipeout' buf
"             " echo buf
"         endif
"     endfor
" endfunction
" dunno why above don't work
let g:specialBufferType_list = ["help", "man"]
function! CloseSpecialBuffers()
    for buf in range(1, bufnr('$'))
        let l:buftype = getbufvar(buf, '&filetype')
        " if l:buftype ==# "help" || l:buftype ==# "man"
        if index(g:specialBufferType_list, l:buftype) >= 0
            execute 'bwipeout' buf
            " echo buf
        endif
    endfor
endfunction
command! CloseSB call CloseSpecialBuffers()

" list unique add (primarily for avoiding option += append duplicates wlet g:startify_session_before_save = [ 'silent! call CloseSpecialBuffers()']hen .vim file sourced twice)
function! ListAddUnique(list, value)
  let l:mutable_list = a:list
  if l:mutable_list->index(a:value) < 0
    let l:mutable_list += [a:value]
  endif
endfunction

" function! DictAddUnique(dict, key, value)
"   if !has_key(a:dict, a:key)
"     let a:dict[a:key] = a:value
"   endif
" endfunction

" arithmetic
" let g:arithmetic_bit_mostSignificant = pow(2, v:numbersize)
function! Sign(x)
  " positive returns 1, negative returns -1, zero returns 0
  if x > 0
    return 1
  elseif x < 0
    return -1
  else
    return 0
  endif
endfunction


" VerityHighlight brought here
function! RangedPattern(startpos, endpos, pattern)
  let [l:startLine, l:startCol] = a:startpos
  let [l:endLine, l:endCol] = a:endpos
  let return_pattern = '\(\%>' . l:startLine . 'l\|\(\%>' . (l:startCol-1) . 'c\&\%' . (l:startLine) . 'l\)\)' . a:pattern . '\(\%<' . l:endLine . 'l\|\(\%<' . (l:endCol+1) . 'c\&\%' . (l:endLine) . 'l\)\)'
  " echom l:return_pattern
  return l:return_pattern
endfunction

function! RangedPattern_startFromCursor_WrapAround(pattern)
  let [l:cusline, l:cuscol] = [line('.'), col('.')]
  let l:firstHalf_start = [l:cusline, l:cuscol]
  let l:firstHalf_end = [line('$'), col([line('$'), '$'])]
  let l:pattern_firstHalf = RangedPattern(l:firstHalf_start, l:firstHalf_end, a:pattern)
  " echo 'wrapped around EOF'
  let l:secondHalf_start = [1, 1]
  let l:secondHalf_end = l:cuscol <= 1 ? [l:cusline - 1, col([line('$') - 1, '$'])] : [l:cusline, l:cuscol - 1]
  let l:pattern_secondHalf = RangedPattern(l:secondHalf_start, l:secondHalf_end, a:pattern)
  return [l:pattern_firstHalf, l:pattern_secondHalf]
endfunction

" backspace cancelable input()
" additional property: when exit via Esc sequence or Bs, v:statusmsg is set to be v:false, otherwise v:true for ditinguish '' input
function! BackspaceCancelable_input(...)
  " use it as if it's an input()
  let storedMapping_rhs = maparg('<backspace>', 'c')
  cnoremap <buffer><expr> <bs> getcmdpos()==1 && getcmdtype()=='@' ? "<Esc>" : "<bs>"
  cnoremap <buffer><expr> <CR> getcmdtype()=='@' ? "<cmd>let v:statusmsg=v:true<CR><CR>" : "<CR>"
  let input_arguments = ""
  if a:0 >= 1
    " let l:input_arguments .= shellescape(a:1)
    let l:input_arguments = '"' . substitute(a:1, '"', '\\"', 'g') . '"'
  endif
  for argn in a:000[1:]
    " let l:input_arguments .= ", " . shellescape(l:argn)
    let l:input_arguments .= ', ' . '"' . substitute(l:argn, '"', '\\"', 'g') . '"'
  endfor
  " echom l:input_arguments
  try
    " input() don't modify this value in any ways (at least that I know of), so change this as default right before input() call can better avoid contamination
    let v:statusmsg = v:false 
    call inputsave()
    execute "let l:returnInput = input(" . l:input_arguments . ")"
    call inputrestore()
    return l:returnInput
  catch
    let this_fname = substitute(expand('<stack>'), '^function \(.*\)\[.\+\]$', '\1', 'g')
    throw expand('<stack>') . " wrapper: " . substitute(v:exception, 'input', l:this_fname, 'g')
  finally
    if l:storedMapping_rhs != ''
      cunmap <buffer> <bs>
      execute "cnoremap <buffer><expr> <bs> " . l:storedMapping_rhs
    endif
  endtry
endfunction

" global set timeout so there's no state change bugs
" just predeclaration, the initial value doesn't matter
let g:changeFileType_savedtimeout = &timeout
let g:changeFileType_savedtimeoutlen = &timeoutlen
function! SetGlobalTimeoutSnapShot(timeout=&timeout, timeoutlen=&timeoutlen)
  " put this at post_config
  let g:changeFileType_savedtimeout = a:timeout
  let g:changeFileType_savedtimeoutlen = a:timeoutlen
  let &timeout = g:changeFileType_savedtimeout
  let &timeoutlen = g:changeFileType_savedtimeoutlen
endfunction

function! SetGlobalTimeout(timeout, timeoutlen)
  " put this at post_config
  " echom "Set - timeoutpre: " . &timeout . ", timeoutpost: " . a:timeout . ", filetype: " . &filetype
  let &timeout = a:timeout
  let &timeoutlen = a:timeoutlen
endfunction
" autocmd! FileType nerdtree echom "NERDTree buffer entered" | autocmd FileType startify echom "Startify buffer entered"

function! ResetGlobalTimeout()
  " echom "Set - timeoutpre: " . &timeout . ", timeoutpost: " . g:changeFileType_savedtimeout . ", filetype: " . &filetype
  let &timeout = g:changeFileType_savedtimeout
  let &timeoutlen = g:changeFileType_savedtimeoutlen
endfunction

" timeout setting for certain filetype
let g:setFileTypeTimeout_customizedList = []
function! SetFiletypeTimeout(type, settimeout = v:true, settimeoutlen = &timeoutlen)
  let g:setFileTypeTimeout_customizedList += [a:type]
  " this only trigger when filetype is set, but need to make sure the buffer we're in right now is the one being set
  " execute "autocmd! BufWinEnter " . a:type . 
  "       \ " if &filetype==" . shellescape(a:type) .
  "       \ " | let &timeout=" . a:settimeout .
  "       \ " | set timeoutlen=" . a:settimeoutlen
  "       \ " | endif"
  " added filename check because nerdtree fucks up autocmd triggering, some unnamed buffer is created and triggering these buffer-local global option setters without re-entering nerdtree buffer
  " TODO get rid of NerdTree
  execute "autocmd! FileType,WinEnter,WinLeave * if index(g:setFileTypeTimeout_customizedList, &filetype) < 0" .
      \ "\ | call ResetGlobalTimeout()" .
      \ "\ | elseif expand('<afile>') != ''" .
      \ "\ | call SetGlobalTimeout(" . a:settimeout . ", " . a:settimeoutlen . ")"
      \ "\ | endif"
  " execute "autocmd! BufEnter * if index(g:setFileTypeTimeout_customizedList, &filetype) < 0" .
  "     \ "\ | call ResetGlobalTimeout() | echom 'Enter reset, file:' .  shellescape(<afile>) " .
  "     \ "\ | else" .
  "     \ "\ | call SetGlobalTimeout(" . a:settimeout . ", " . a:settimeoutlen . ") | echom 'Enter set, file:' .  shellescape(<afile>)" .
  "     \ "\ | endif" .
  " execute "autocmd! BufLeave * if index(g:setFileTypeTimeout_customizedList, &filetype) < 0" .
  "     \ "\ | call ResetGlobalTimeout() | echom 'Leave reset, file:' .  shellescape(<afile>) " .
  "     \ "\ | else" .
  "     \ "\ | call SetGlobalTimeout(" . a:settimeout . ", " . a:settimeoutlen . ") | echom 'Leave set, file:' .  shellescape(<afile>)" .
  "     \ "\ | endif"
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
command! -nargs=* QLstop call s:QLstop(<f-args>)

" function! _test()
"   let l:current_line = getline('.')
" 	if match(l:current_line, 'END') != -1
" 		echoerr "End Of Recursive Macro"
"   endif
" endfunction