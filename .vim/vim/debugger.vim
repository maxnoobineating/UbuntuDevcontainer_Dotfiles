" C quick bootup
function Debugger_quick_c()
  let output = system("gcc -Wall -g -o ./debugger_quick_c " . expand("%:p") . " -lm 2>&1")
  echom output
  if v:shell_error
    EchomWarn "compilation failed!"
    return
  endif
  " let dict = {
  " \ "configurations": {
  "   \  "Launch C": {
  "     \    "adapter": "cppdbg",
  "     \    "configuration": {
  "       \      "request": "launch",
  "       \      "program": expand("%:p:h") . "/debugger_quick_c"
  "       \      "args": [],
  "       \      "cwd": expand("%:p:h"),
  "       \      "environment": [],
  "       \      "stopAtEntry": 1
  "   \    }
  "   \  }
  " \ }
  " \}
  let dict = {
  \ "configurations": {
  \   "Launch C": {
  \     "adapter": "cppdbg",
  \     "configuration": {
  \       "request": "launch",
  \       "program": expand("%:p:h") . "/debugger_quick_c",
  \       "args": [],
  \       "cwd": expand("%:p:h"),
  \       "environment": [],
  \       "stopAtEntry": 1
  \     }
  \   }
  \ }
  \}

  call vimspector#LaunchWithSettings(dict)
endfunction
let g:Debugger_quickDebuggerList = {
    \ "c": function("Debugger_quick_c")
    \ }
function Debugger_quick()
  if !g:Debugger_quickDebuggerList->has_key(&filetype)
    EchomWarn 'filetype="' . &filetype . '" does not have build/debug tool setup!'
    return
  endif
  call g:Debugger_quickDebuggerList[&filetype]()
endfunction
nnoremap <expr> <leader>di Debugger_quick()



" vimrc debugger
if !exists("s:vimscriptDebugger_switchOn") || !s:vimscriptDebugger_switchOn
  finish
endif

let s:vimscriptDebugger_scriptPath = expand('<sfile>:p')

" usage: vim -c "VimscriptDebuggerOn"
" command! VimscriptDebuggerOn echom "debugger file path: " . s:vimscriptDebugger_scriptPath
let s:vimscriptDebugger_switchOn = v:false
command! VimscriptDebuggerOn execute "source " . s:vimscriptDebugger_scriptPath
      \ | let s:vimscriptDebugger_switchOn = v:true
      \ | call writefile(["", "VimscriptDebuggerOn -- " . strftime("%c") . " --", ""], s:debugAutocmd_file, "a")
" command! VimscriptDebuggerOff autocmd! DebugAutocmd | let s:vimscriptDebugger_switchOn = v:false
"       \ | call writefile(["", "VimscriptDebuggerOff -- " . strftime("%c") . " --", ""], s:debugAutocmd_file, "a")
command! VimscriptDebuggerOff autocmd! DebugAutocmd | let s:vimscriptDebugger_switchOn = v:false

let s:debugAutocmd_file = "./autocmd_messages"
" reltime() returns metrics on 0.01 ms (5 digits) e.g. 100 ms should be 10000
let s:batchWork_batchRefreshTime = 10000
let s:batchWork_timeUp = v:numbermax
let s:separator_line = '################################################################8#'
function! s:DebugAutocmd_logSeparator_callback(timer_id)
  if s:batchWork_timeUp <= reltime()[1]
    let destination_message = "* end at file=" . expand("%")
    echom "callback! timeUp=" . s:batchWork_timeUp . ", reltime=" . reltime()[1]
    call writefile([l:destination_message, s:separator_line], s:debugAutocmd_file, "a")
    let s:batchWork_timeUp = v:numbermax
  endif
endfunction

function! s:DebugAutocmdFunction(fileName, fileType, winid, autocmdName, customCmd = 'silent echo ""')
  execute "redir >> " . s:debugAutocmd_file
    if s:batchWork_timeUp == v:numbermax
      silent echon "* start at file=" . expand("%") . "\n"
      let action_description = input("What's the action? ")
      silent echo "Action: " . l:action_description . "\n"
    endif
    " silent echon "[" . strftime("%c") . "] " . a:autocmdName . ' - fileName: ' . a:fileName . ', &filetype=' . a:fileType . ', winid=' . a:winid
    silent echon "[" . strftime("%T") . "] " . a:autocmdName
          \ . ' - fileName=' . (empty(expand('<afile>')) ? '<none>' : expand('<afile>'))
          \ . ', &filetype=' . (empty(&filetype) ? '<none>' : &filetype)
          \ . ', &buftype=' . (empty(&buftype) ? 'normal' : &buftype)
          \ . ', tabnr/total=' . tabpagenr() . '/' . tabpagenr('$')
          \ . ', winid=' . a:winid
    execute a:customCmd
  redir END
  let s:batchWork_timeUp = reltime()[1] + s:batchWork_batchRefreshTime
  call timer_start(s:batchWork_batchRefreshTime / 100, function('s:DebugAutocmd_logSeparator_callback'))
endfunction

let g:debugAutocmd_option = ['BufLeave', 'BufEnter', 'BufRead', 'BufDelete', 'BufAdd', 'BufCreate', 'BufNew', 'BufWipeout', 'BufUnload', 'BufHidden', 'BufWinEnter', 'BufWinLeave', 'WinNew', 'WinEnter', 'WinLeave', 'WinClosed', 'TabNew', 'TabEnter', 'TabLeave', 'TabClosed']

augroup DebugAutocmd
  autocmd!
  for acmd in g:debugAutocmd_option
    execute "autocmd " . acmd
          \ . " * call s:DebugAutocmdFunction(expand('<afile>'), &filetype, win_getid(), '"
          \ . acmd . "')"
  endfor
  let s:vimLeaveCmd = substitute("silent echo \"\n\" . repeat(\"=\", (&columns-20)/2 ) . \" End of Session \" . repeat(\"=\", (&columns-20)/2 ) . \"\n\n\n.\n\"", '\n', '\\n', 'g')
  " autocmd VimLeave * execute "call s:DebugAutocmdFunction(" . shellescape(expand('<afile>')) . ", " . shellescape(&filetype) . ", 'VimLeave', " . shellescape(s:vimLeaveCmd) . ")"
  autocmd VimLeave * execute "call s:DebugAutocmdFunction(expand('<afile>'), &filetype, win_getid(), 'VimLeave', " . shellescape(s:vimLeaveCmd) . ")"
augroup END


  " autocmd WinLeave * call DebugAutocmdFunction(expand('<afile>'), &filetype, 'WinLeave')
  " " autocmd WinEnter * call DebugAutocmdFunction(expand('<afile>'), &filetype, 'WinEnter')
  " autocmd TabLeave * call DebugAutocmdFunction(expand('<afile>'), &filetype, 'TabLeave')
  " " autocmd TabEnter * call DebugAutocmdFunction(expand('<afile>'), &filetype, 'TabEnter')
  " autocmd BufWinLeave * call DebugAutocmdFunction(expand('<afile>'), &filetype, 'BufWinLeave')
  " " autocmd BufWinEnter * call DebugAutocmdFunction(expand('<afile>'), &filetype, 'BufWinEnter')
  " autocmd BufLeave * call DebugAutocmdFunction(expand('<afile>'), &filetype, 'BufLeave')
  " " autocmd Bufread * call DebugAutocmdFunction(expand('<afile>'), &filetype, 'Bufread')
  " " autocmd BufEnter * call DebugAutocmdFunction(expand('<afile>'), &filetype, 'BufEnter')
  " " autocmd BufCreate * call DebugAutocmdFunction(expand('<afile>'), &filetype, 'BufCreate')
  " autocmd BufDelete * call DebugAutocmdFunction(expand('<afile>'), &filetype, 'BufDelete')
  " " autocmd FileType * call DebugAutocmdFunction(expand('<afile>'), &filetype, 'FileType')
  " autocmd VimLeavePre * call DebugAutocmdFunction(expand('<afile>'), &filetype, 'VimLeavePre')