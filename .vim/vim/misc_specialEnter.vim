" Enter based mapping
" implicit category: insert/create things

" create a timer
nnoremap <expr> <CR>t TimerReminder()
" Define a function to parse the input and start the timer.
function! TimerReminder() abort
  " Prompt for time input. Examples: "10m", "1hr", "30s", or just "30"
  let inp = input('Enter time (e.g. 10m, 1hr, 30s): ')
  let number_pat = '\(\d\+\|\d*\.\d\+\)\ze'
  let hr = inp->matchstr(number_pat . '\(hr\|h\)')->str2float()
  let min = inp->matchstr(number_pat . '\(min\|m\)')->str2float()
  let sec = inp->matchstr(number_pat . '\(sec\|s\)')->str2float()

  " Start the timer that will call s:show_reminder after l:ms milliseconds.
  call timer_start(float2nr(hr * 36000000 + min * 60000 + sec * 1000), function('s:show_reminder'))
  EchomWarn "Timer set for " . hr . " hrs " . min . " mins " . sec . " s"
endfunction

" This function is called when the timer expires.
function! s:show_reminder(timer) abort
  " Define the message to display.
  let l:msg = 'Time is up!'
  " Set popup options.
  let l:opts = {
        \ 'minwidth': len(l:msg) + 4,
        \ 'borderchars': ['─', '│', '─', '│', '╭',  '╮', '╯', '╰'],
        \ 'padding': [0,1,0,1],
        \ 'highlight': 'CocFloating',
        \ 'borderhighlight': ['CocFloating'],
        \ 'filter': function('s:close_popup'),
        \ 'mapping': v:false
        \ }
  " Create the popup; store its id in a script variable.
  let s:popup_winid = popup_dialog([l:msg], l:opts)
  " call win_execute(s:popup_winid, 'nnoremap <buffer><nowait> <CR> <CR>')
endfunction

" This filter function is called on any keypress inside the popup.
function! s:close_popup(id, key) abort
  " Close the popup window.
  if a:key ==? 'q' || a:key == "\<CR>" || a:key == "\<Esc>" || a:key ==? "x"
    call popup_close(a:id)
  endif
  " Return the key so that normal key processing continues.
  return a:key
endfunction


" new lining selected item and autoformat
vnoremap <CR><CR> c<CR><CR><Up><Esc>p==

" open vimscript command window
" execute selected script
let s:misc_specialEnter_openCMDWindow_filePath = '/tmp/vim/misc_specialEnter/'
if !isdirectory(s:misc_specialEnter_openCMDWindow_filePath)
  call system('mkdir -p ' . s:misc_specialEnter_openCMDWindow_filePath)
endif
let s:misc_specialEnter_openCMDWindow_filePattern = 'openCMDWindow_'
function! OpenNewCMDWindow() abort
  let current_winid = win_getid()
  " let tempfilePath = systemlist('mktemp '
  "       \ . s:misc_specialEnter_openCMDWindow_filePath
  "       \ . s:misc_specialEnter_openCMDWindow_filePattern . 'XXXXXX')[0]
  " if v:shell_error != 0
  "   throw expand("<stack>") . " - temp file creation error: " . tempfilePath
  " endif
  if !exists('t:misc_specialEnter_openCMDWindow_trackingIndex')
    let t:misc_specialEnter_openCMDWindow_trackingIndex = len(g:misc_specialEnter_openCMDWindow_history)
  endif
  " let g:misc_specialEnter_openCMDWindow_history += [tempfilePath]
  silent! execute "botright 9split +enew"
  " only for this unname buffer
  setlocal bufhidden=wipe
  call s:OpenCMDWindowFile(g:misc_specialEnter_openCMDWindow_history[-1], current_winid)
endfunction

function! s:OpenCMDWindowFile(filePath, acting_winid) abort
  try
    silent! write
  catch
    EchomWarn v:exception
    throw expand("<stack>") . " - cannot save before opening new CMDWindow file"
  endtry
  let fullPath = a:filePath
  silent! execute "edit " . fullPath
  " execute "autocmd! BufLeave * ++once call delete(".shellescape(l:tempfile).")"
  nnoremap <buffer><nowait> q <cmd>autocmd! BufEnter * ++once redraw!<CR><cmd>wq<CR>
  execute 'nnoremap <buffer> <Esc>[1~ <cmd>call OpenCMDWindowPrev('.a:acting_winid.')<CR>'
  execute 'nnoremap <buffer> <Esc>[4~ <cmd>call OpenCMDWindowNext('.a:acting_winid.')<CR>'
  execute 'nnoremap <buffer> <CR>n <cmd>call OpenCMDWindowNewFile('.a:acting_winid.')<CR>'
  execute 'nnoremap <buffer><nowait> <CR>c <cmd>w<CR><cmd>call win_execute('
        \ . a:acting_winid . ', '
        \ . shellescape('source ' . fullPath)
        \ . ')<CR><cmd>autocmd! BufEnter * ++once redraw!<CR><cmd>q<CR>'
  execute 'nnoremap <buffer> <CR>i <cmd>call OpenCMDWindow_verbosePreFill()<CR>'

  setlocal bufhidden=delete
  setlocal filetype=vim
  call ChooseFiletypeFzf()
  if &filetype != "vim"
    nnoremap <buffer> <CR>c <NOP>
  endif
endfunction
function! OpenCMDWindowNext(acting_winid) abort
  if t:misc_specialEnter_openCMDWindow_trackingIndex < (len(g:misc_specialEnter_openCMDWindow_history) - 1)
    let t:misc_specialEnter_openCMDWindow_trackingIndex += 1
    let cmdWindow_filePath = g:misc_specialEnter_openCMDWindow_history[t:misc_specialEnter_openCMDWindow_trackingIndex]
    call s:OpenCMDWindowFile(cmdWindow_filePath, a:acting_winid)
    return
  else
    EchomWarn "CMD Window: already at the newest CMDWindow!"
    return
  endif
endfunction
function! OpenCMDWindowPrev(acting_winid) abort
  if t:misc_specialEnter_openCMDWindow_trackingIndex > 0
    let t:misc_specialEnter_openCMDWindow_trackingIndex -= 1
    let cmdWindow_filePath = g:misc_specialEnter_openCMDWindow_history[t:misc_specialEnter_openCMDWindow_trackingIndex]
    call s:OpenCMDWindowFile(cmdWindow_filePath, a:acting_winid)
    return
  else
    EchomWarn "CMD Window: already at the oldest CMDWindow!"
    return
  endif
endfunction
function! OpenCMDWindowNewFile(acting_winid) abort
  let tempfilePath = systemlist('mktemp '
        \ . s:misc_specialEnter_openCMDWindow_filePath
        \ . s:misc_specialEnter_openCMDWindow_filePattern . 'XXXXXX')[0]
  if v:shell_error != 0
    throw expand("<stack>") . " - temp file creation error: 
" . tempfilePath
  endif
  let t:misc_specialEnter_openCMDWindow_trackingIndex = len(g:misc_specialEnter_openCMDWindow_history)
  let g:misc_specialEnter_openCMDWindow_history += [tempfilePath]
  call s:OpenCMDWindowFile(tempfilePath, a:acting_winid)
endfunction


if !exists('g:misc_specialEnter_openCMDWindow_history')
  let g:misc_specialEnter_openCMDWindow_history = GetFilesByAccessTime(
        \ s:misc_specialEnter_openCMDWindow_filePath,
        \ s:misc_specialEnter_openCMDWindow_filePattern . '*')
endif
nnoremap <CR>c <cmd>call OpenNewCMDWindow()<CR>

" TODO verbose invoke existing command/function/let/set/etc..., format them so it's easily editable for execution
function! OpenCMDWindow_verbosePreFill() abort
  let script_target = BackspaceCancelable_input("prefill: verbose ", "", "expression")
  let script = OpenCMDWindow_parseVerbose(script_target)
  put =script
endfunction
function! OpenCMDWindow_parseVerbose(script_target) abort
  let [script_type, arg_start, _] = a:script_target->matchstrpos('^\s*\zs\S\+\ze')
  " if arg_start < 0 || !(script_type->IsIn([
  "       \ 'function',
  "       \ 'command',
  "       \ 'map',
  "       \ 'set',
  "       \ 'highlight',
  "       \ 'autocmd']))
    " EchomWarn "Non-valid verbose type!"
    " return
  " endif
  try
  redir => script_msg
    execute 'verbose ' . a:script_target
  redir END
  catch
    EchomWarn expand("<stack>") . " - invalid verbose highlight command!"
    throw v:exception
  return
  endtry
  let script_msglist = script_msg->split('')
  if script_type == 'function'
  " template:
  "    function CMDFunc(cmd)
  "         Last set from ~/.vim/vim/functions.vim line 78
  " 1    try
  " 2      execute a:cmd
  " 3    catch
  " 4      echoerr v:exception
  " 5      return v:false
  " 6    endtry
  " 7    return v:true
  "    endfunction
    let indent_level = script_msglist[0]->matchstr('^\s*')->strlen()
    let head = script_msglist[0]->substitute('^\s*\%(function\|fu\)!\?', 'function!', 'g')
    let body = script_msglist[2:]
    if len(body) != 0
      eval body->map('v:val[' . indent_level . ':]')
    endif
    let function_script = ([head] + body)->join('')
    return function_script
  elseif script_type == 'command'
    EchomWarn "To be implemented!"
  elseif script_type == 'map'
    EchomWarn "To be implemented!"
  elseif script_type == 'set'
    EchomWarn "To be implemented!"
  elseif script_type == 'highlight'
    EchomWarn "To be implemented!"
  elseif script_type == 'autocmd'
    EchomWarn "To be implemented!"
  else
    EchomWarn "Non-valid verbose type!"
  endif
  return ''
endfunction