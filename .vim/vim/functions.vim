"=============================================================================="
" Functions
function! All(list, func)
  " Iterate over each item in the list
  let boolList = list->map(func)
  for item in boolList
    " Call the function on the item; if it returns 0 (false), return 0
    if !item
      return 0
    endif
  endfor
  " If we made it through the loop, all items passed
  return 1
endfunction


" return list of file names ordered from oldest to latest under given dir, matching given wildcard
function! GetFilesByAccessTime(path, pattern)
    " Construct the shell command
    let l:cmd = 'find '. a:path
          \ . ' -maxdepth 1 -type f -name ' . shellescape(a:pattern)
          \ . ' -printf "%A@ %p\n" | sort -n | cut -d" " -f2'
    " Execute the command and capture the output
    let l:file_list = systemlist(l:cmd)
    return l:file_list
endfunction


" comparing if given buffer is the same file as <path>
function BufnrPathEq(bufnr, path)
  return a:bufnr->bufname()->fnamemodify(':h')->fnamemodify(':p')
        \ == a:path->fnamemodify(':p')
endfunction

" range compare
" function! RangeComp(lrange, rrange)
"   " return -2 for [  ] < >, -1 for [ < ] > , 0 for {  }, 1 for < [ > ], 2 for < > [  ]
"   if lrange[0] < rrange[0] || (lrange[0] == rrange[0] && lrange[1] < rrange[1])
"   elseif lrange[0] < rrange[0] || (lrange[0] == rrange[0] && lrange[1] < rrange[1])
"   elseif lrange[0] < rrange[0] || (lrange[0] == rrange[0] && lrange[1] < rrange[1])
"   elseif lrange[0] < rrange[0] || (lrange[0] == rrange[0] && lrange[1] < rrange[1])
"   endif
" endfunction

" timer
let s:reltimeTimer_tracker = {}
function! ReltimeTimer_mus(name, time)
" v:true if it's over a:time since last time ReltimeTimer(a:name, ...) is called
  let reltime_diff = ReltimeDiff(reltime(), s:reltimeTimer_tracker->get(a:name, [0, 0]))
  let s:reltimeTimer_tracker[a:name] = reltime()
  return reltime_diff > a:time
endfunction
function! ReltimeTimer(name, time)
  return ReltimeTimer_mus(a:name, a:time * 1000000)
endfunction

" &tagfunc= called by :tag... etc 
function! TestTagfunc(pattern, flag, info)
  echom "pattern: " . string(a:pattern)
  echom "flag: " . string(a:flag)
  echom "info: " . string(a:info)
  return [{'name': 'haha', 'filename': './nani', 'cmd': "read ./~zshrc"}]
endfunction

" keystroke capturing abstract
" XXX it's recursive with feedkeys...
" function! CaptureKeyMapping(mapFunc)
"   " mapFunc is a funcref that takes a list (representing keypresses recorded so far), returns 1 to continue capturing, 0 to exit
"   let recording = []
"   while(1)
"     let l:recording += [getchar()]
"     if !a:mapFunc(l:recording)
"       return
"     endif
"   endwhile
" endfunction
" " nnoremap <C-t><C-t>
" function! CKInput(keysList)
"   if(nr2char(a:keysList[-1]) ==# "\<CR>")
"     return v:false
"   endif
"   echom "you pressed [" . nr2char(a:keysList[-1]) . "]"
"   call feedkeys(nr2char(a:keysList[-1]))
"   return v:true
" endfunction
" inoremap <nowait> <C-t> <cmd>call CaptureKeyMapping(function('CKInput'))<CR>

" warning echom
command! -nargs=* EchomWarn echohl WarningMsg | echo <args> | echohl None

" return funcref for executing command, return v:true if executed without error
function! CMDFunc(cmd)
  try
    execute a:cmd
  catch
    echoerr v:exception
    return v:false
  endtry
  return v:true
endfunction
function! CMDFuncRedir(cmd)
  let msg = ''
  redir => msg
    silent! if !CMDFunc(a:cmd)
      let msg = ''
    endif
  redir END
  return msg
endfunction
function! CMDFuncref(cmd)
  return Curry(function('CMDFunc'), a:cmd)
endfunction

" time diff between objects returns by reltime()
function! ReltimeDiff(reltime0, reltime1)
  return (a:reltime0[0] - a:reltime1[0]) * 1000000 + (a:reltime0[1] - a:reltime1[1])
endfunction

" restoring tabdo
function! Tabdo(cmd)
  let old_tabpagenr = tabpagenr()
  execute "tabdo " . a:cmd
  execute l:old_tabpagenr . "tabnext"
endfunction

" is in / contains
function! Contains(object, value)
  if type(a:object) == v:t_string
    return match(a:object, '\V' . a:value) >= 0
  elseif type(a:object) == v:t_list
    return index(a:object, a:value) >= 0
  elseif type(a:object) == v:t_dict
    return index(a:object->keys()) >= 0
  else
    throw expand("<stack>") . " - wrong arg type!"
  return
endfunction
function! Isin(value, object)
  return Contains(a:object, a:value)
endfunction

" currying
function! Curry(fn, ...) abort
  " Capture the initial arguments
  let args = a:000
  return {... -> call(a:fn, args + a:000)}
endfunction

" autocmd SourcePre * ++once command! presource -nargs=*
command! -nargs=* Sourcepost execute "autocmd SourcePost * ++once ++nested " . <q-args>

" Clear unused buffers
function! CloseUnusedBuffers()
  for bufinfo in getbufinfo()
    " echom "bufnr: " . l:bufinfo.bufnr . ", name: " . l:bufinfo.name
    if !filereadable(l:bufinfo.name) && !l:bufinfo.changed
      " echom "out!"
      execute "bdelete " . l:bufinfo.bufnr
    endif
  endfor
endfunction

" special type of buffer/file
let g:specialFileType_list = ["help", "man"]
let g:specialBufferType_list = ["help", "nofile"]
function! IsSpecialFileType(filetype)
  return a:filetype->Isin(g:specialFileType_list)
endfunction
function! IsSpecialBuffer(buftype)
  return a:buftype->Isin(g:specialBufferType_list)
endfunction
function! CloseSpecialBuffers()
    for buf in range(1, bufnr('$'))
        let l:buftype = getbufvar(buf, '&buftype')
        " if l:buftype ==# "help" || l:buftype ==# "man"
        if l:buftype->Isin(g:specialBufferType_list)
            execute 'bwipeout! ' . buf
            " echo buf
        endif
    endfor
endfunction
function! CloseSpecialFiles()
    for buf in range(1, bufnr('$'))
        let l:filetype = getbufvar(buf, '&filetype')
        " if l:buftype ==# "help" || l:buftype ==# "man"
        if l:filetype->Isin(g:specialFileType_list)
            execute 'bwipeout! ' . buf
            " echo buf
        endif
    endfor
endfunction
command! CloseSB call CloseSpecialBuffers()
command! CloseSF call CloseSpecialFiles()

" list unique add (primarily for avoiding option += append duplicates wlet g:startify_session_before_save = [ 'silent! call CloseSpecialBuffers()']hen .vim file sourced twice)
function! ListAddUnique(list, value)
  let l:mutable_list = a:list
  if l:mutable_list->index(a:value) < 0
    let l:mutable_list += [a:value]
  endif
endfunction

function! ListAppendUnique(list, appList)
  for item in a:appList
    eval a:list->ListAddUnique(l:item)
  endfor
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
  let return_pattern = '\%(\%>' . l:startLine . 'l\|\%(\%>' . (l:startCol-1) . 'c\&\%' . (l:startLine) . 'l\)\)' . a:pattern . '\%(\%<' . l:endLine . 'l\|\%(\%<' . (l:endCol+1) . 'c\&\%' . (l:endLine) . 'l\)\)'
  " echom l:return_pattern
  return l:return_pattern
endfunction
" #40ffff
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

function! ConfirmActOnMatchings(pattern)
  
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