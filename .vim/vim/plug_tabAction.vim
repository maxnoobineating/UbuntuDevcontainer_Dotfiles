" tabline action
" move tab
" nnoremap <C-w>< :tabmove -1<CR>
" nnoremap <C-w>> :tabmove +1<CR>
nnoremap <C-t>< :<C-u>execute 'tabmove -' . (v:count1)<CR>
nnoremap <C-t>> :<C-u>execute 'tabmove +' . (v:count1)<CR>
" switch to last active tab
nnoremap <C-Home> g<tab>
" close current tab
nnoremap <silent> <C-End> :tabclose!<CR>


function! TabAction_SessionTabVariables_define()
  let t:tabCreation_time = reltime()
  let t:tabAction_tabSessionId = s:TabAction_tabSession_genTabSessionId()
endfunction
augroup TabAction
  autocmd!
  autocmd TabNew * call TabAction_SessionTabVariables_define()
        " \ | echom "TabAction: tabCreationTime[" . tabpagenr() ."] - " string(t:tabCreation_time)
  autocmd VimEnter * call Tabdo(
        \ "call TabAction_SessionTabVariables_define()")
        " \ . ' | echom "tabCreationTime[" . tabpagenr() ."] - " string(t:tabCreation_time)')
  autocmd TabLeave * let g:lasttab = tabpagenr('#')
  autocmd BufHidden * let g:closedbufFileName_pre = expand('<afile>:p')
  autocmd TabClosed * let g:closedbufFileName += [g:closedbufFileName_pre]
  autocmd TabClosed * if g:lasttab > 1 | execute "normal! " . g:lasttab . "gt" | endif
  " autocmd TabClosed * let g:lastClosedTabnr = tabpagenr()
  " autocmd TabClosed * call s:TabAction_saveTabSession()
augroup END
let s:tabAction_startify_before_save_cmd = [
      \ 'autocmd! TabAction',
      \ 'call CloseSpecialBuffers()',
      \ 'call TabAction_tabSession_sessionBeforeSave()']
let s:tabAction_startify_load_cmd = [
      \ 'call TabAction_tabSession_sessionAfterLoad()']
let s:tabAction_startify_savevars = [
        \ 'g:tabAction_sessionUniqueID_saver']
" eval g:startify_session_savevars->ListAddUnique('g:tabAction_tabids')
" the order of execution is important here, or tabpagenr won't return accurate pages
" XXX broken by reordering - fk me
" Sourcepost eval g:startify_session_before_save->ListAppendUnique(s:tabAction_startify_before_save_cmd)
" Sourcepost eval g:startify_session_savecmds->ListAppendUnique(s:tabAction_startify_load_cmd)
" Sourcepost eval g:startify_session_savevars->ListAppendUnique(s:tabAction_startify_savevars)

" function! TestSessionUniqueID()
"   echom "session unique id = " . g:tabAction_sessionUniqueID
"   let g:tabAction_sessionUniqueID += 1
" endfunction

if !exists('g:tabAction_tabids')
  let g:tabAction_tabidsaved = {}
endif

function! GetSUID()
  return s:tabAction_sessionUniqueID
endfunction

if !exists('s:tabAction_sessionUniqueID')
  " script variable cannot be saved..
  if exists('g:tabAction_sessionUniqueID_saver')
    unlockvar g:tabAction_sessionUniqueID_saver
    let s:tabAction_sessionUniqueID = g:tabAction_sessionUniqueID_saver
    unlet g:tabAction_sessionUniqueID_saver
  else
    let s:tabAction_sessionUniqueID = 0
  endif
elseif exists('g:tabAction_sessionUniqueID_saver')
  " for whatever reason
  unlockvar g:tabAction_sessionUniqueID_saver
  unlet g:tabAction_sessionUniqueID_saver
endif

function! TabAction_tabSession_sessionBeforeSave()
  if exists('s:tabAction_sessionUniqueID')
    let g:tabAction_sessionUniqueID_saver = s:tabAction_sessionUniqueID
    lockvar g:tabAction_sessionUniqueID_saver
  else
    let g:tabAction_sessionUniqueID_saver = 0
    lockvar g:tabAction_sessionUniqueID_saver
  endif
  let saved_tabnr = tabpagenr()
  " save tabIds
  " winid persist in the same session between startup
  tabdo if exists('t:tabAction_tabid')
        \ | let g:tabAction_tabidsaved[win_getid(1)] = t:tabAction_tabid
        \ | endif
  execute l:saved_tabnr . "tabnext"
endfunction

function! TabAction_tabSession_sessionAfterLoad()
  if !exists('s:tabAction_sessionUniqueID')
    " script variable cannot be saved..
    if exists('g:tabAction_sessionUniqueID_saver')
      unlockvar g:tabAction_sessionUniqueID_saver
      let s:tabAction_sessionUniqueID = g:tabAction_sessionUniqueID_saver
      unlet g:tabAction_sessionUniqueID_saver
    else
      let s:tabAction_sessionUniqueID = 0
    endif
  elseif exists('g:tabAction_sessionUniqueID_saver')
    " for whatever reason
    unlockvar g:tabAction_sessionUniqueID_saver
    unlet g:tabAction_sessionUniqueID_saver
  endif

  let saved_tabnr = tabpagenr()
  " winid persist in the same session between startup
  tabdo if g:tabAction_tabidsaved->has_key(win_getid(1))
        \ | let t:tabAction_tabid = g:tabAction_tabidsaved[win_getid()]
        \ | endif
  execute l:saved_tabnr . "tabnext"
endfunction

function! s:TabAction_escape(string)
  " escape ':', '/', '//', '\', '\\'
  " return a:string->substitute('\(\\\\\|\/\/\|\\\|\/\)', '=+', 'g')->escape(':')
  return a:string->substitute('\(\\\\\|\/\/\|\\\|\/\)', '=+', 'g')->fnameescape()->escape(':')
endfunction

function! s:TabAction_listReadableFileNameInTab()
  for winnr in range(1, tabpagewinnr(tabpagenr(), '$'))
    let bufnr = winbufnr(winnr)
    let bufname = bufname(bufnr)
    if !empty(bufname)
        echo 'Window ' . winnr . ': ' . bufname
    endif
  endfor
endfunction

let s:pid_max_filePath = '/proc/sys/kernel/pid_max'
if filereadable(s:pid_max_filePath) && v:numbersize <= log10(str2nr(readfile(s:pid_max_filePath)[0]))
  " 64 bits vim (19 digits)
  " vimPID limit set in /proc/sys/kernel/pid_max (typically around 5 digits)
  " monthlySysTime reset every 2592000 (7 digits)
  " sessionUniqueId reset every 1000 times (3 digits)
  echoerr expand('<stack>') . " Warning! - potential overflow of tabSessionId"
endif
function! s:TabAction_tabSession_genTabSessionId()
  " <tabSessionId> == <vimPID><monthlySysTime><sessionId>
  let secondsInAMonth = 3600 * 24 * 30
  let seconds_everyMonth = float2nr(fmod(localtime(), l:secondsInAMonth)) " seconds count that reset every 30 days
  let returnId = str2nr(getpid() . l:seconds_everyMonth . s:tabAction_sessionUniqueID)
  let s:tabAction_sessionUniqueID = float2nr(fmod(s:tabAction_sessionUniqueID + 1, 1000))
  return l:returnId
endfunction

let s:tabAction_tabSession_sessionFileNamePrefix = 'tabAction_tabSession'
function! s:TabAction_tabSessionFileName()
  " <s:tabAction_tabSession_sessionFileNamePrefix>:<sessionPath>:<tabSessionId>.vim
  " e.g. "tabAction_tabSession:=+root=+.vim=+session=+vimrc:48667285761.vim"
  let l:current_sessionPath = v:this_session->TabAction_escape()
  " let l:current_filePath = expand('%:p:gs?\(/\|\\\)?=+?')->escape(":")
  let
  let tabSession_fileName =
        \ s:tabAction_tabSession_sessionFileNamePrefix . ':'
        \ . l:current_sessionPath . ':'
        \ . TabAction_tabSession_genTabSessionId()
        \ . ".vim"
  return l:tabSession_fileName
endfunction

function! s:TabAction_tabSessionFileNameInterpret(fileName)
  " return a list containing
  " [ "project session path", "vimPID", "tabSessionId" ]
  " or returning [] if the file isn't a tabSession file
  let l:errorMsg = expand('<stack>') . a:fileName . " not a tabSession file"
  if !assert_match('\_.*\.vim$', a:fileName, l:errorMsg)
    return []
  endif
  " let l:noFileExtension_name = substitute(a:fileName, "\.vim$", '', '')
  let l:noFileExtension_name = a:fileName[:-len('.vim') - 1]
  let returned_list = l:noFileExtension_name->split('\\\@<!:', v:true)
  if(len(l:returned_list) != 4
    \ || l:returned_list[0] != s:tabAction_tabSession_sessionFileNamePrefix
    \ || string(str2nr(l:returned_list[2])) != l:returned_list[2])
    \ || string(str2nr(l:returned_list[3])) != l:returned_list[3])
    echoerr l:errorMsg
    return []
  endif
  return returned_list[1:]
endfunction

" session don't have a 'default' directory
let g:sessiondir = split(&runtimepath, ',')[0] . "/session/"
if !isdirectory(g:sessiondir) | call mkdir(g:sessiondir, "p") | endif
function! s:TabAction_saveTabSession()
  let errorMsg = expand('<stack>') . " - "
  " Full session as project, tab session as layout history
  " save per-tab session under each full session v:this_session
  " otherwise lump them together as loner tab history (project session name == '')
  let this_session_dirName = fnamemodify(v:this_session, ':t')
  let l:this_session_dirName = l:this_session_dirName == '' ? 'tabSession_default' : l:this_session_dirName
  let currentSession_tabSessionDir = fnamemodify(g:sessiondir, ':h') . "/" . l:this_session_dirName . "/"
  if(!isdirectory(l:currentSession_tabSessionDir))
    call mkdir(l:currentSession_tabSessionDir, "p")
  endif
  let tabSessionFileName = l:currentSession_tabSessionDir . s:TabAction_tabSessionFileName()
  while filereadable(l:tabSessionFileName)
    echoerr l:errorMsg . "wut!? tab session file already exists? how?"
    let l:tabSessionFileName = l:currentSession_tabSessionDir . s:TabAction_tabSessionFileName()
  endif
  " remove loaded tabsession file
  let old_sessionoptions = &sessionoptions
  let old_sessionName = v:this_session
  let new_sessionoptions_list = split(l:old_sessionoptions, ',')
  while index(l:new_sessionoptions_list, 'tabpages') >= 0
    let l:new_sessionoptions_list = remove(l:new_sessionoptions_list, index(l:new_sessionoptions_list, 'tabpages'))
  endwhile
  call TabAction_cleanTabSessionFiles(l:currentSession_tabSessionDir)
  let &sessionoptions = join(l:new_sessionoptions_list, ',')
  execute "mksession! " . l:tabSessionFileName
  let &sessionoptions = l:old_sessionoptions
  let v:this_session = l:old_sessionName
endfunction

function s:TabAction_clearItem(list, removingItem)
  while index(a:list, a:removingItem) >= 0
    call remove(a:list, index(a:list, a:removingItem))
  endwhile
endfunction

" TODO shelf this utility until I finish adapting to buffer-as-tab work flow (implementing bufferline)
" XXX main challenge - when to trigger mksession for the whole tab?
" it's expensive, also no event is triggered exactly before tab is about to close and nothing has been changed yet
" (the closest one is BufLeave, but that's triggered too often, so you'll likely want to only store some information first, 
" then do full tab config save when the TabLeave sequence is confirmed, hence all the variable necessary should be stored along the
" BufLeave -> WinLeave -> TabLeave sequence, and you'll probably need an entirely customized mksession anyway... that's hella of work)
function TabAction_tabSession_saveAsTab(fileName)
  " echom "nani!?"
  let old_sessionoptions = &sessionoptions
  let old_sessionName = v:this_session
  let new_sessionoptions_list = split(l:old_sessionoptions, ',')
  call s:TabAction_clearItem(l:new_sessionoptions_list, 'tabpages')
  call s:TabAction_clearItem(l:new_sessionoptions_list, 'options')
  let &sessionoptions = join(l:new_sessionoptions_list, ',')
  " echom &sessionoptions
  execute "silent! mksession! " . a:fileName
  let &sessionoptions = l:old_sessionoptions
  " because v:this_session will be changed to the latest executed mksession (globally),
  " you need to restore it in case startify session persistent is set
  let v:this_session = l:old_sessionName
  " call timer_start(1000, function('s:EchoAh'))
endfunction


let s:tabAction_tabSession_sessiondirSizeLimit = 1000000 " 1MB limit
function! TabAction_cleanTabSessionFiles(tabSessionDir)
  let wc_systemScript = "wc -c " . g:sessiondir . s:tabAction_tabSession_sessionFileNamePrefix . "*.vim | awk '{print $1}'"
  let sessionFile_totalSize = systemlist(l:wc_systemScript)[-1]
  " echom "sessionFile_totalSize = " . string(sessionFile_totalSize)
  if str2nr(sessionFile_totalSize) < s:tabAction_tabSession_sessiondirSizeLimit
    return
  endif
  " echom "nani!?"
  " if session dir total size exceed the allowed limit, delete the oldest accesed ones until reaching
  let stat_systemScript = "stat --format='%X:%s:%n' " . g:sessiondir . s:tabAction_tabSession_sessionFileNamePrefix . "*.vim | sort -n"
  let sessionFile_list = systemlist(l:stat_systemScript)
  for l:sessionFile in l:sessionFile_list
    " echom "sessionFile " . string(l:sessionFile)
    if l:sessionFile_totalSize < s:tabAction_tabSession_sessiondirSizeLimit | break | endif
    let oldestAccessedFile_statList = split(l:sessionFile, ':')
    let oldestAccessedFile_fileSize = l:oldestAccessedFile_statList[0]
    " to prevent ':' being used in session file name messing up the result
    let oldestAccessedFile_fileName = g:sessiondir . split(join(l:oldestAccessedFile_statList[2:], ':'), '/')[-1]
    if delete(l:oldestAccessedFile_fileName) == 0
      " echom l:oldestAccessedFile_fileName . " deleted, Size: " . l:oldestAccessedFile_fileSize ." bytes released!"
      let l:sessionFile_totalSize -= l:oldestAccessedFile_fileSize
    endif
  endfor
endfunction

function! s:TabAction_loadTabSession_inNewTab()
  " execute "source " . 
  if(empty(&viewdir))
    return
  endif
  " we'll use last modified ftime to store our view files
  let tabSessionFileName = &viewdir . "/"
        \ . s:tabAction_tabSession_sessionFileNamePrefix
        \ " expand path name and replace '/' or '\' with '=+' (just like default :mkview)
        \ . expand('%:p:gs?\(/\|\\\)?=+?') . ':'
        \ . string(getftime())
  if !filereadable(l:tabSessionFileName)
    echom expand('<stack>') . ": file hasn't been modified."
    return
  endif
  execute "silent! mkview " . l:tabSessionFileName
endfunction

if !exists('g:closedbufFileName')
  let g:closedbufFileName = [] 
endif
nnoremap <C-t> <nop>
nnoremap <C-t>r <cmd>noautocmd execute g:closedbufFileName->len() > 0 ? "TabDrop e " . g:closedbufFileName->remove(-1) : "EchomWarn 'No prior closed tab!'"<CR>

function! GotoTabID(tabid)
  let tabnr = index(map(gettabinfo(), 'has_key(v:val.variables, "tabAction_tabSessionId") ? v:val.variables.tabAction_tabSessionId : -1'), a:tabid)
  " echom "GotoTab - " . l:tabnr
  if l:tabnr >= 0
    execute "tabnext " . (l:tabnr + 1)
    return v:true
  else
    return v:false
  endif
endfunction

let s:tabAction_TabDropTimerlen = 20 " ms
function! TabAction_getTabDropTimerlen()
  return s:tabAction_TabDropTimerlen
endfunction
function! TabDropCMD(...)
  " if received command creates a new window in current tab, or changes current window buffer, create a new tab instead
  " also, if created lone-window-buffer tab is a duplicates, delete other dups
  let l:before_winids = gettabinfo('.')[0].windows
  let l:before_winbufnrs = map(copy(l:before_winids), 'v:val->winbufnr()')
  let l:before_tabid = t:tabAction_tabSessionId

  let l:reltime = reltime()
  " echom "before tab winids=" . string(l:before_winids)
  " echom "before tab winbufnrs=" . string(l:before_winbufnrs)
  execute join(a:000, ' ')

  " let l:destination_winid = s:TabDropCMDpost_tabnew(l:before_winids, l:before_winbufnrs, l:before_tabid, 0)
  " call s:TabDropCMDpost_filterTabs(l:reltime, 0)
  " for use in autocmd when like BufEnter ... when the state probably isn't as flexible?
  call timer_start(s:tabAction_TabDropTimerlen,
        \ Curry(function('s:TabDropCMDpost_tabnew'),
          \ l:reltime,
          \ l:before_winids,
          \ l:before_winbufnrs,
          \ l:before_tabid))
endfunction

function! ListTabIDs()
  return map(gettabinfo(), 'v:val.variables.tabAction_tabSessionId')
endfunction

function! s:TabDropCMDpost_tabnew(reltime, before_winids, before_winbufnrs, before_tabid, timer_id)
  let l:after_tabid = t:tabAction_tabSessionId
  let l:destination_winid = win_getid()
  let l:destination_curpos = getcurpos(l:destination_winid)
  " echom "after tab " . a:before_tabid . " :" . string(ListTabIDs())
  if GotoTabID(a:before_tabid)
    " echom "before tab " . l:after_tabid . " :" . string(ListTabIDs())
    let l:after_originalTab_winids = gettabinfo('.')[0].windows
    let l:after_originalTab_winbufnrs = map(copy(l:after_originalTab_winids), 'v:val->winbufnr()')
    " echom "after original tab winids=" . string(l:after_originalTab_winids)
    " echom "after original tab winbufnrs=" . string(l:after_originalTab_winbufnrs)
    let before_ind = 0
    for before_winid in a:before_winids
      let ind = index(l:after_originalTab_winids, l:before_winid)
      if l:ind < 0 || l:after_originalTab_winbufnrs[l:ind] == a:before_winbufnrs[l:before_ind]
        continue
      endif
      execute 'tabnew +b\ ' . l:after_originalTab_winbufnrs[l:ind]
      if l:before_winid == l:destination_winid
        let l:destination_winid = win_getid()
      endif
      call win_gotoid(l:before_winid)
      if bufexists(a:before_winbufnrs[l:before_ind])
        execute 'b ' . a:before_winbufnrs[l:before_ind]
      else
        close
      endif
      let l:before_ind += 1
    endfor
    " call GotoTabID(l:after_tabid)
    for after_winid in l:after_originalTab_winids
      if l:after_winid->Isin(a:before_winids)
        continue
      endif
      call win_gotoid(l:after_winid)
      wincmd T
      if l:after_winid == l:destination_winid
        let l:destination_winid = win_getid()
      endif
    endfor
  endif
  call s:TabDropCMDpost_filterTabs(a:reltime, 0)
  call win_gotoid(l:destination_winid)
  " echom string(l:destination_curpos)
  call cursor(l:destination_curpos[1:])
  filetype detect " for when sometimes filetype won't load, dunno why
  " call win_gotoid(l:destination_winid)
  
  return l:destination_winid
endfunction

" open tab with command, if already exists in tabs, switch to it
" let s:tabProcessingReltime_limit = 100000 " 100 ms
function! s:TabDropCMDpost_filterTabs(reltime, timer_id)
  " echom "TabDropCMD_post: reltime=" . string(a:reltime)
  " if ReltimeDiff(reltime(), a:reltime) > s:tabProcessingReltime_limit
  "   return
  " endif
  let [l:prev_time_s, l:prev_time_us] = a:reltime
  let l:newlyCreated_tabs_loneBufnr = []
  " echom gettabinfo()
  for l:tabinfo in gettabinfo()
    if !has_key(l:tabinfo.variables, 'tabCreation_time')
      continue
    endif
    let [l:tabCtime_s, l:tabCtime_us] = l:tabinfo.variables.tabCreation_time
    if (l:tabCtime_s > l:prev_time_s
          \ || (l:tabCtime_s == l:prev_time_s
            \ && l:tabCtime_us > l:prev_time_us))
          \ && len(l:tabinfo.windows) == 1
      let l:newlyCreated_tabs_loneBufnr += [l:tabinfo.windows[0]->winbufnr()]
    endif
  endfor
  " echom "newly created tabs bufnr: " . string(l:newlyCreated_tabs_loneBufnr)
  let deleteList = []
  for l:tabinfo in gettabinfo()
    " echom "tab[" . l:tabinfo.tabnr . "] - windows:" . string(l:tabinfo.windows) . ", bufnr:" . string(map(l:tabinfo.windows, 'v:val->winbufnr()'))
    if !has_key(l:tabinfo.variables, 'tabCreation_time')
      continue
    endif
    let [l:tabCtime_s, l:tabCtime_us] = l:tabinfo.variables.tabCreation_time
    if (l:tabCtime_s < l:prev_time_s
          \ || (l:tabCtime_us < l:prev_time_us
            \ && l:tabCtime_s == l:prev_time_s))
        \ && len(l:tabinfo.windows) == 1
        \ && l:tabinfo.windows[0]->winbufnr()->Isin(l:newlyCreated_tabs_loneBufnr)
      let l:deleteList += [l:tabinfo.tabnr]
    endif
  endfor
  " echom "deleted list: " . string(l:deleteList)
  let closedTabs = 0
  for deletetabnr in l:deleteList
    execute "tabclose! " . (l:deletetabnr - l:closedTabs)
    " echom "tabclose! " . (l:deletetabnr - l:closedTabs)
    let l:closedTabs += 1
  endfor
endfunction
command! -nargs=* TabDrop call TabDropCMD(<f-args>)

function! RecursiveAutocmdDeleteTabs(tabnrList)
  if empty(a:tabnrList)
    return
  endif
  call OpenedTabs()
  execute "tabclose! " . a:tabnrList[0]
  execute "autocmd! TabClosed * ++once ++nested call RecursiveAutocmdDeleteTabs(" . string(a:tabnrList[1:]) . ")"
endfunction

function! OpenedTabs()
  let openedTabsList = []
  let tabinfoList = gettabinfo()
  for l:tabinfo in l:tabinfoList
    let l:openedTabsList += [l:tabinfo['tabnr']]
  endfor
  echom string(l:openedTabsList)
endfunction