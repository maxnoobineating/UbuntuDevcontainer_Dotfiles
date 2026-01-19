" #===================================================================================#
" === Close-Quickfix Mapping === // replaced by all quickfix quit in the same tab
" augroup QuickfixClose
"   autocmd!
"   autocmd FileType qf nnoremap <buffer><nowait> q :q<CR>
" augroup END


" dunno why but <C-i> jump list undo is remapped to tag jump...
nnoremap <C-i> <C-I>

" ; . (originally ,) motion for selection
" noremap . ,

" wait, why does this work now? (probably because I've remapped <alt-hjkl> keycode)
nmap  <Plug>CommentaryLine<CR>
vmap  <Plug>Commentary<CR>

" ctrl + PageUp/PageDown/End/Home in insert/cmd mode should behave like normal mode
noremap! <C-PageUP> <Esc><C-PageUp>
noremap! <C-PageDown> <Esc><C-PageDown>
noremap! <C-Home> <Esc><C-Home>
noremap! <C-End> <Esc><C-End>

" command to open ftplugin file for current filetype
function! OpenFileTypeConfig()
  let path = "$HOME/.vim/ftplugin/" . &filetype . ".vim"
  if filereadable(expand(path))
    execute "TabDrop tabnew " . expand(path)
  else
    EchomWarn "filetype " . &filetype . " config at " . expand(path) . " doesn't exist!"
  endif
endfunction
command! OpenFtplug call OpenFileTypeConfig() 

" disable visual lowercasing with u, change it to undo
vnoremap u <nop>
vnoremap u <Esc>u

" nnoremap <C-j> :cn<CR>
" nnoremap <c-k> :cp<CR>
" set <Home>=[1~
" set <End>=[4~
" set <C-Home>=[1;5H
" set <C-End>=[1;5F
nnoremap <leader>cn :silent! TabDrop cn<CR>
" nnoremap <kHome> <cmd>silent! TabDrop cp<CR>
nnoremap <leader>cp :silent! TabDrop cp<CR>
" nnoremap <End> <cmd>silent! TabDrop cn<CR>
" nnoremap <kHome> <cmd>echom "asd"<CR>

" large change warning for when accidental changes covers most of window s.t. it goes unnoticed
let s:prev_yankreg = ''
function! MiscFunc_checkForLargeChange()
  let l:change_tolerance = getwininfo(win_getid())[0]['height'] * 0.40
  if (s:prev_yankreg != @" && count(@", "\n") >= l:change_tolerance) || abs(line("'[") - line("']")) >= l:change_tolerance
    echohl WarningMsg | echo "\rWarning! major changes to the buffer" | echohl None
  endif
  let s:prev_yankreg = @"
endfunction
augroup MiscOnChange
  autocmd! TextChanged * if &buftype == '' | call MiscFunc_checkForLargeChange() | endif
augroup END


" don't do :R, you'll accidentally trigger :r
nnoremap <C-w>r <cmd>source ~/.vimrc<CR>

" map nnoremap r to macro recording (q), because r replacement mode single replace is useless (R line replace is still there)
if maparg('q', 'n')==''
  nnoremap q <nop>
  nnoremap <nowait> q <cmd>windo if &filetype == 'qf' \| quit \| endif<CR><cmd>echo "quit quickfix; recording remapped to r"<CR>
endif
nnoremap r q
vnoremap r q

" cmdline window buffer mappings
function! ConfigureCmdwinBuffer()
  " cmdline window reopen exec
  nnoremap <buffer> <F5> <CR>q:
  " cmdline disable insert Enter and C-c behaviour for typical insert mode experience
  " imap <buffer> <CR> <nop>
  " execute "inoremap <buffer> <CR> " . maparg('<CR>', 'i') == '' ? "<CR>" : maparg('<CR>', 'i')
  " inoremap <buffer> <CR> <c-o>o<c-o>==
  " this works, but breaks at first col
  inoremap <buffer> <CR> <c-o>"="\r"<CR>p<c-o><cmd>let cmdlineWin_tempBuffer=@/<CR><cmd>s/\r/\r/<CR><cmd>let @/=cmdlineWin_tempBuffer<CR>
  " imap <buffer> <C-c> <nop>
  " execute "inoremap <buffer> <C-c> " . (maparg('<C-c>', 'i') == '' ? "<C-c>" : maparg('<C-c>', 'i'))
  " cadline window visual exec multicmd
  vnoremap <buffer> <CR> <nop>
  vnoremap <buffer> <CR> y<cmd>let @0=substitute(substitute(substitute(@0, '\n\+$', '', 'g'), '\n', ' \\n ', 'g'), '^\s*\\', '', 'g')<CR><cmd>q<CR>:<C-U>exe "<C-R>0"<CR>
endfunction
autocmd CmdwinEnter * call ConfigureCmdwinBuffer()

" disable /? search enter jumping, but still allows incsearch (it snaps back to original place when confirm the search)
" cnoremap <expr> <CR> getcmdtype()=='/' \|\| getcmdtype()=='?' ? "<CR>``" : "<CR>"
" make canceling / search still retain the search result without jump
" cnoremap <nowait> <Esc> <Esc>
" map my most comfortable escape combo to not cancel search

" <c-q> will get you [Z] but [Z is the correct one, dunno why
" (it's probably not a normal vs insert difference in keycode, <A-kjhl> all have the same keycode without ']')
set <S-Tab>=[Z]
set <S-Tab>=[Z
set <A-k>=k
set <A-j>=j
set <A-h>=h
set <A-l>=l
noremap <A-k> <Esc>gk
noremap <A-j> <Esc>gj
noremap <A-h> <Esc>h
noremap <A-l> <Esc>l
inoremap <A-k> <Esc>gk
inoremap <A-j> <Esc>gj
inoremap <A-h> <Esc>h
inoremap <A-l> <Esc>l
vnoremap <A-h> <Esc>`<h
vnoremap <A-j> <Esc>`>gj
vnoremap <A-k> <Esc>`<gk
vnoremap <A-l> <Esc>`>l
cnoremap <expr> <A-k> getcmdtype()=='/' \|\| getcmdtype()=='?' ? "<CR>``" : "<CR>"
cnoremap <expr> <A-j> getcmdtype()=='/' \|\| getcmdtype()=='?' ? "<CR>``" : "<CR>"
cnoremap <expr> <A-h> getcmdtype()=='/' \|\| getcmdtype()=='?' ? "<CR>``" : "<CR>"
cnoremap <expr> <A-l> getcmdtype()=='/' \|\| getcmdtype()=='?' ? "<CR>``" : "<CR>"
" for preventing Surround from interpreting escaping motion as a special character
" XXX not working
" onoremap <A-k> <Esc>k
" onoremap <A-j> <Esc>j
" onoremap <A-h> <Esc>h
" onoremap <A-l> <Esc>l

" <c-v> visual mode blocked by terminal
set <A-v>=v
nnoremap <A-v> <C-v>
vnoremap <A-v> <C-v>

" mouse click for displaying synID
let g:Misc_mappings_echoSynFunc = 'synIDattr(v:val, "name")'
" let g:Misc_mappings_echoSynFunc = { ind, val -> synIDattr(val, "name") }
function! EchoSynIDNameStack()
  let stackIDs = synstack(line('.'), col('.'))
  let stackIDs_mapped = stackIDs->copy()->map(g:Misc_mappings_echoSynFunc)
  let stackIDsTrans = stackIDs->copy()->map('synIDtrans(v:val)')
  let stackIDsTrans_mapped = stackIDsTrans->copy()->map(g:Misc_mappings_echoSynFunc)
  let stackNames = []
  for ind in range(len(stackIDs))
    if stackIDs[ind] != stackIDsTrans[ind]
      let stackNames += [stackIDs_mapped[ind].'>'.stackIDsTrans_mapped[ind]]
    else
      let stackNames += [stackIDs_mapped[ind]]
    endif
  endfor
  echom "synstack(line=" . line('.') . ", col=" . col('.') .  ")=[ " . stackNames->join(', ') . " ]"
endfunction
" nnoremap <leftmouse> <leftmouse>:echom "synstack(line=" . line('.') . ", col=" . col('.') .  ") = " . synstack(line('.'), col('.'), 0)->map('synIDtrans(v:val)')<CR>
nnoremap <leftmouse> <leftmouse><cmd>call EchoSynIDNameStack()<CR>

" the holy ctrl-s
nnoremap <C-s> :wa<CR>

" disable insert mode ^ combo key
inoremap <nowait> ^ ^

" enable man.vim
runtime! ftplugin/man.vim
let g:ft_man_open_mode = 'tab'
" Man page search *man* *manpage* *:Man*
" man achieves c-] keyword jumping without tagfile by using keywordprg=<command> option
function! OpenManpage()
  let l:text = BackspaceCancelable_input("Man:", "", "custom,")
  if(l:text == "")
    return
  endif
  let existence = systemlist("/bin/man -w " . l:text . " 2>/dev/null 1>/dev/null || echo $?")
  " echom "existence: " . string(existence)
  if  existence->len() > 0 && existence[0] == '16'
    if system(l:text . " --help 2>/dev/null 1>/dev/null || echo $?") == ''
      echom "\ralternative " . l:text . " --help generated"
      " execute "tab terminal sh -c " . shellescape(l:text . " --help | eval $MANPAGER")
      " use the special behaviour with vim terminal cat, it will bring the file up like a normal buffer
      let temp_helpfile = systemlist("man -w " . l:text)[0]
      execute "tab terminal cat " . l:temp_helpfile
      set filetype=man
      redraw!
      call timer_start(10, {_ -> CMDFunc("call cursor([1, 1])")})
    elseif system(l:text . " help 2>/dev/null 1>/dev/null || echo $?") == ''
      echom "\ralternative " . l:text . " help generated"
      let temp_helpfile = systemlist("man -w " . l:text)[0]
      execute "tab terminal cat " . l:temp_helpfile
      set filetype=man
      redraw!
      call timer_start(10, {_ -> CMDFunc("call cursor([1, 1])")})
    else
      EchomWarn "\rNo '" . l:text . " --help' command found"
    endif
  else
      " default manpage doesn't exist for the keyword
    let l:manpage_msg = ''
    " let old_eventignore = &eventignore
    " let &eventignore.=',User ALEWantResults'
    redir => l:manpage_msg
      silent! execute "TabDrop Man " . l:text
    redir END
    " let &eventignore = l:old_eventignore
    " return cursor to beginning for later messaage to write properly
    " echom l:manpage_msg
    " XXX below is due to IndentLinesReset autocmd...
    " workaround indentline exclude not working properly
    " call timer_start(TabAction_getTabDropTimerlen(), { timer_id -> CMDFunc("call feedkeys(\":IndentLinesDisable\\<CR>\")") })
    " autocmd! CursorMoved,CursorHold * ++once call feedkeys(":IndentLinesDisable\<CR>")
  endif
endfunction
nnoremap <leader>! :call OpenManpage()<CR>


" native tag jump c-] / going back c-^
" going back 1 in tagStack
nnoremap <C-\> <C-T>


" Mappings
" open help file prompt
function! OpenHelpFile()
  let l:text = BackspaceCancelable_input("Help:", "", "help")
  if(l:text == "")
    return
  endif
  try
    if l:text[0] == '/'
      let pattern = l:text[1:]
      silent! call TabDropCMD("helpgrep \\v\\c" . pattern)
    else
      let pattern = "\\V\\c*\\.\\*" . l:text . "\\.\\**"
      silent! call TabDropCMD("helpgrep ". pattern)
    endif
    let fullqflist = getqflist()
    if fullqflist->len() <= 0
      echo "\rNo help page found for " . l:text
      return
    endif
    " let newqflist = fullqflist->filter('v:val.bufnr->bufname()->fnamemodify(":h") == g:helpPage_builtinqflist->map("v:val.bufnr")') + g:helpPage_builtinqflist
    let newqflist = fullqflist->copy()->filter({_, val -> BufnrPathEq(val.bufnr, $VIMRUNTIME . "/doc")})
          \ + fullqflist->copy()->filter({_, val -> !BufnrPathEq(val.bufnr, $VIMRUNTIME . "/doc")})
    silent! call setqflist(newqflist, 'r')
    silent! crewind
  catch
    echo "\rNo help page found for " . l:text . "\nError: " . v:errmsg
    return
  endtry
  " call timer_start(10, {_ -> CMDFunc("tag /\\c" . pattern)})
  " execute "tab help " . l:text
  " let oldpos = getpos('.')
  " call cursor(oldpos)
endfunction
nnoremap <leader>? :call OpenHelpFile()<CR>
" put this in ~/.vim/ftplugin/help.vim as filetype plugin (*ftplugin*) for help buffer
" augroup HelpPage
"   autocmd!
"   autocmd! FileType help nnoremap <buffer> <end> :tnext<CR>
" echom "haha!"
"   autocmd! FileType help nnoremap <buffer> <home> :tprevious<CR>
" augroup END

" function signiture related
function! GenHeader_function(file)
    let l:base_dir = expand('%:p:h')
    " let l:file_path = fnamemodify(a:file, ':p', l:base_dir)
    let l:line_before = line("$")
    " execute "read !ctags --fields=+S -x --c-kinds=f " . shellescape(a:file) . " | awk '{sub(/\{/, \"\", $0); print substr($0, index($0,$5))}'"
    execute "read !ctags --fields=+S -x --c-kinds=f " . fnameescape(l:base_dir . '/' . a:file) . " | awk '{sub(/\{/, \"\", $0); print substr($0, index($0,$5))}'"

    let l:line_after = line("$")
    call StripWhitespace()
    execute (line(".") - (l:line_after - l:line_before) + 1) . "," . line(".") . "s/$/;/"
endfunction
" nnoremap <Leader>gh :new %:t:r.h \| read !ctags -x --c-kinds=f % | awk '{print $1"();"}'<CR>
" command! -nargs=1 GenHeader read !ctags -x --c-kinds=f <args> | awk '{print $1"();"}'
" command! -nargs=1 GenHeader read !ctags --fields=+S -x --c-kinds=f <args> | awk '{print $1" "$4";"}'
" command! -nargs=1 GenHeader read !ctags --fields=+S -x --c-kinds=f <args> | awk '{sub(/\{/, "", $0); print substr($0, index($0,$5))}'<CR> \| call StripWhitespace()<CR>
" command! -nargs=1 GenHeader execute "read !ctags --fields=+S -x --c-kinds=f " . shellescape(<args>) . " | awk \"{sub(/\\{/, "", $0); print substr($0, index($0,$5))}\"" \|
"     \ let l:start_line = line("'[") \|
"     \ call StripWhiteSpace() \|
"     \ execute l:start_line . ",$s/$/;/"
command! -nargs=1 -complete=file GenHeader call GenHeader_function(<f-args>)


" search pattern pre-fill
" reserve s register for matched text
" nnoremap ;; :%s:::c<C-b><right><right><right>
" nnoremap ;' :%s:::n<C-b><right><right><right>
" vnoremap ;; <Esc>:'<,'>s:\%V::c<C-b><right><right><right><right><right><right><right><right><right><right>
" vnoremap ;' <Esc>:'<,'>s:\%V::n<C-b><right><right><right><right><right><right><right><right><right><right>

" search in recently selected lines
nnoremap <leader>/ /\%V
vnoremap <leader>/ <Esc>/\%V

" ========================================================================="

" Keybinding Mappings
inoremap <C-k> <C-o>d$
inoremap <C-b> <C-o>d^

" undo line with <leader>ul
nnoremap <leader>ul U
nnoremap U <C-r>

" selection replacement
function! ReplaceWithInput()
  " let choice = confirm("Replacing highlighted text?", "&Yes\n&No\n&Quit", 1)
  " if choice != 1
  "     return 0
  " endif
  " no longer needed cuz able to cancel with esc/bs
  " call search(@h, 'bc')  " put cursor on the head of matched pattern
  " let l:cuscol = col('.')
  " let l:cusline = line('.')
  let [l:cusline, l:cuscol] = searchpos(@h, 'bc')
  " let l:old_pattern = substitute(getreg('h'), '\\<\|\\>', '', 'g')
  let l:default_text = matchstr(getline(l:cusline)[l:cuscol-1:], @h)
  let l:replacement_text = BackspaceCancelable_input('Enter replacement text: ', l:default_text, 'tag')
  if v:statusmsg != v:true " no valid input is entered
    return
  endif
  " let l:replacement_text = escape(l:replacement_text, '\/.^$*[]~')
  let s:replacement_nr = 0
  let s:lastEdit_cursorpos = []
  function! s:replacementReturn(text)
    " echom "#text=" . shellescape(a:text)
    let s:replacement_nr += 1
    let s:lastEdit_cursorpos = getcurpos('.')
    let ret_text = a:text->copy()
    let cpgroup_ind = ret_text->match('\\\d')
    let cpgroup_matchStart = 0
    while cpgroup_ind >= 0
      let cpgroup_nr =  ret_text[cpgroup_ind + 1]->str2nr()
      let cpgroup_text = submatch(cpgroup_nr)
      " let cpgroup_text = cpgroup_text->substitute('\\\d', '\="\\".submatch(0)', 'g')
      let ret_text = (cpgroup_ind > 0 ? ret_text[:cpgroup_ind-1]:'') . cpgroup_text . ret_text[cpgroup_ind+2:]
      " echom "#[".cpgroup_ind."="  . shellescape(cpgroup_text) . "]ret_text=" . shellescape(ret_text)
      " to avoid recursively submatch capture groups that contains \\\d
      let cpgroup_matchStart = cpgroup_ind + cpgroup_text->strlen()
      let cpgroup_ind = ret_text->match('\\\d', cpgroup_matchStart)
    endwhile
    return ret_text
  endfunction
  " cursor to end + start to cursor - faulty, cuz the first highlight will most certainly be skipped
  let [l:pattern_firstHalf, l:pattern_secondHalf] = RangedPattern_startFromCursor_WrapAround(@h)
  let l:replacement_nr_max_str = ''
  redir => l:replacement_nr_max_str
    execute "%s/" . l:pattern_firstHalf ."//ne"
  redir End
  let l:replacement_nr_max = str2nr(matchstr(l:replacement_nr_max_str, '\d\+'))
  " echom "replacement number max: " . l:replacement_nr_max
  execute "%s/" . l:pattern_firstHalf . "/\\=s:replacementReturn(" . shellescape(l:replacement_text) . ")/ce"
  " echom "replacement number max: " . l:replacement_nr_max
  if s:replacement_nr == l:replacement_nr_max
    echo 'wrapped around EOF'
    execute "%s/" . l:pattern_secondHalf . "/\\=s:replacementReturn(" . shellescape(l:replacement_text) . ")/ce"
  endif
  call cursor(s:lastEdit_cursorpos[1:])
endfunction
vnoremap <silent> <C-r> "hy:<C-u>silent call ReplaceWithInput()<CR>
" if cursor on top of match highlights, enter replacing commands
" nnoremap <expr> <C-r> IsOnMatch() ? ':call search(@/, "cb")<CR>v//e<CR>"hy:<C-u>call ReplaceWithInput()<CR>' : '<C-r>'
" matching replacement with @/ stored inside @h instead of copy the first match literally as the pattern
nnoremap <silent> <expr> <C-r> IsOnMatch() ? ':let @h=@/<CR>:call ReplaceWithInput()<CR>' : '<C-r>'
 

" mapping yh
let s:confirmAndAppend_modificationTimes = 0
function! s:ConfirmAndAppend(match)
  if s:confirmAndAppend_modificationTimes != 0
    noautocmd undojoin
  endif
  noautocmd let s:confirmAndAppend_modificationTimes += 1
  noautocmd call setreg('0', a:match . "\n", 'a')
  noautocmd return a:match
endfunction

function! YankAppendHighlighted() range
  let @0 = ''
  set hlsearch
  call search(@/, 'cw')
  let [l:pattern_firstHalf, l:pattern_secondHalf] = RangedPattern_startFromCursor_WrapAround(@/)
  let old_pattern = @/
  let s:confirmAndAppend_modificationTimes = 0
  noautocmd let [old_modiviable, old_readonly] = [&modifiable, &readonly]
  noautocmd setlocal modifiable
  noautocmd setlocal noreadonly
  noautocmd let @/ = l:pattern_firstHalf
  noautocmd %s//\=s:ConfirmAndAppend(submatch(0))/ce
  noautocmd let @/ = l:pattern_secondHalf
  noautocmd %s//\=s:ConfirmAndAppend(submatch(0))/ce
  noautocmd let @/ = l:old_pattern
  " noautocmd execute s:confirmAndAppend_modificationTimes . "undo" 
  " noautocmd undo
  noautocmd let [&modifiable, &readonly] = [l:old_modiviable, l:old_readonly]
endfunction
" save all matching into register separated by \n
" nnoremap yh :let @0=''<CR>:%s//\=ConfirmAndAppend(submatch(0))/c<CR>doautocmd WSLYank TextYankPost<CR>
" nnoremap yh :let @0=''<CR>:%s/\v(\_.+)/\=ConfirmAndAppend(submatch(0))/gn<CR>doautocmd WSLYank TextYankPost<CR>
nnoremap yh <cmd>call YankAppendHighlighted() \| call ExportClipboard(@0)<CR>


function! CursorOutsideMatch(match) abort
    " return 0 if cursor on match, 1 if match after cursor, -1 vice versa
    let l:curline = getpos('.')[1]
    let l:curcol = getpos('.')[2]
    if l:curline == a:match.start[0] && l:curcol < a:match.start[1]
        return 1
    endif
    if l:curline == a:match.end[0] && l:curcol > a:match.end[1]
        return -1
    endif
    if l:curline == a:match.start[0] || l:curline == a:match.end[0]
        return 0
    endif
    if l:curline < a:match.start[0]
        return 1
    endif
    if l:curline > a:match.end[0]
        return -1
    endif
    return 0
endfunction
" return the match under cursor if matched, else {}
function! MatchUnderCursor() abort
    " THIS DOESN'T WORK WITH MULTILINE PATTERNS, fck Vim weirdness... why is getting matched text position so hard!?
    " n: nojump, c: include first char of match, b: search behind
    " backward search (b) until the first matching head ( works for cursor on the match and on the match head (c) )
    " let l:matchstart = searchpos(@/, 'Wncb')
    " " forward search until the first matching tail (e), including cursor on tail (c)
    " let l:matchend = searchpos(@/, 'Wnce')
    " let l:matchnext = searchpos(@/, 'wnc')
    " if (l:matchstart[0] != 0) && (l:matchend[0] != 0)
    "     return ((l:matchend[1] < l:matchnext[1]) || (l:matchnext[1] <= l:matchstart[1])) && (l:matchstart[0] == l:matchend[0])
    " endif
    " return 0
    " new implementation using MatchAllPos
    for l:match in MatchAllPos()
        if CursorOutsideMatch(l:match) == 0
            return l:match
        endif
    endfor
    return {}
endfunction

function! IsOnMatch() abort
    if !&hlsearch
        return 0
    endif
    if search(@/, 'cbwn')
        return !empty(MatchUnderCursor())
    endif
    return 0
endfunction

" Function to find all match positions
let g:verity_match_positions = []
function! MatchAllPos() abort
    let g:verity_match_positions = []
    let l:oldpos = getpos('.')
    silent execute '%s/' . @/ . '/\=RegisterMatchPos()/ne'
    call setpos('.', l:oldpos)
    " for l:match in g:verity_match_positions
    "     echo 'Start: ' . l:match.start[0] . ', ' . l:match.start[1] . '\nEnd: ' . l:match.end[0] . ', ' . l:match.end[1]
    " endfor
    return g:verity_match_positions
endfunction

function! RegisterMatchPos() abort
    let l:start_pos = getpos('.')
    " call input('cursor: ' . start_pos[1] . ', ' . start_pos[2])
    let l:matched_text = submatch(0)
    " call input('submatch:' . escape(matched_text, "\n"))
    let l:start_line = l:start_pos[1]
    let l:start_col = l:start_pos[2]
    " Split the matched text by newlines
    let l:lines = split(l:matched_text, "\n", 1)
    let l:matched_len = len(l:matched_text)
    let l:end_lineEnd_char = l:matched_text[l:matched_len-1]
    " If the match spans multiple lines
    if l:end_lineEnd_char == "\n"
        let l:end_line = l:start_line + count(l:matched_text, "\n") - 1
        let l:end_col = len(l:lines[len(l:lines)-2]) + 1
    else
        let l:end_line = l:start_line + count(l:matched_text, "\n")
        if l:start_line == l:end_line
            let l:end_col = l:start_col + len(l:lines[len(l:lines) - 1]) - 1
        else
            let l:end_col = len(l:lines[len(l:lines) - 1])
        endif
    endif
    " Append the positions to the global verity_match_positions array
    call add(g:verity_match_positions, {'start': [l:start_line, l:start_col], 'end': [l:end_line, l:end_col]})
    " Return the matched text to keep the substitution operation transparent
    return l:matched_text
endfunction


" Ctrl+n to select matched text
function! NearestMatch(flag) abort
    " Initialize variables to track the nearest match
    " let l:old_cur = getpos('.')
    let l:pos_ls = MatchAllPos()
    " call cursor(l:old_cur)
    if empty(l:pos_ls)
        return {}
    endif
    if a:flag == -1
        call reverse(l:pos_ls)
    endif
    for l:match in l:pos_ls
        let l:cur_mat_pos = CursorOutsideMatch(l:match)
        if l:cur_mat_pos == a:flag
            return l:match
        endif
    endfor
    return {}
endfunction

function! SelectNextMatch(flag) abort
    let l:next_match = NearestMatch(a:flag)
    if empty(l:next_match)
        return 0
    endif
    call cursor(l:next_match.start)
    " selecting twice because, when using normal to enter visual mode, if you don't leave visual mode once apparently vim don't register the '<'> range
    execute 'normal! v' . l:next_match.start[0] . 'G' . l:next_match.start[1] . '|o' . l:next_match.end[0] . 'G' . l:next_match.end[1] . "|\<Esc>gv"
    " call input( 'range: ' . getpos("'<")[1] . ', ' . getpos("'<")[2])
endfunction

function! IsSelected() abort
    let l:current_match = NearestMatch(0)
    if empty(l:current_match)
        return 0
    endif
    return getpos("'<")[1:2] == l:current_match.start && getpos("'>")[1:2] == l:current_match.end
endfunction

function! VerityHighlight_N(flag) abort
    if IsOnMatch()
        call SelectNextMatch(0)
    else
        call SelectNextMatch(a:flag)
    endif
endfunction

function! VerityHighlight_V(flag) abort
    if !IsSelected() && IsOnMatch()
        call SelectNextMatch(0)
    else
        call SelectNextMatch(a:flag)
    endif
endfunction

" Ctrl+n to select matched text
nnoremap <silent> <Plug>VerityHighlightNext_N :call VerityHighlight_N(1)<CR>
vnoremap <silent> <Plug>VerityHighlightNext_V <Esc>:call VerityHighlight_V(1)<CR>
nnoremap <silent> <Plug>VerityHighlightPrev_N :call VerityHighlight_N(-1)<CR>
vnoremap <silent> <Plug>VerityHighlightPrev_V <Esc>:call VerityHighlight_V(-1)<CR>
" nmap <silent> <C-n> <Plug>VerityHighlightNext_N
" vmap <silent> <C-n> <Plug>VerityHighlightNext_V
" nmap <silent> <C-p> <Plug>VerityHighlightPrev_N
" vmap <silent> <C-p> <Plug>VerityHighlightPrev_V
" fk me
nnoremap <C-n> ngn
vnoremap <C-n> <Esc>ngn
nnoremap <C-p> NgN
vnoremap <C-p> <Esc>NgN


" visual to the end don't enclude newline
vnoremap _ $
vnoremap - $h


" two way expansion of visual selection
vnoremap L <Esc>`<v`>loho
vnoremap H <Esc>`<v`>holo


" C-u C-r in insert mode for undo/redo
inoremap <C-u> <C-o>u
" inoremap <C-r> <C-o><C-r>

" change 'w' word motion behaviour to excludes '_'
function! CustomWordMotion(cmd)
    let old_iskeyword=&iskeyword
    set iskeyword-=_
    execute "normal! " . a:cmd
    let &iskeyword=old_iskeyword
endfunction

nnoremap w :call CustomWordMotion('w')<CR>
" nnoremap daw :call CustomWordMotion('daw')<CR>
" nnoremap diw :call CustomWordMotion('diw')<CR>
" use visual mode to change word is because command will exit insert mode
" recursively linked to aw/iw below
" nmap caw vawc
" nmap ciw viwc
" nmap cw viwc
" nmap daw vawd
" nmap diw viwd
" nmap dw viwd
" vnoremap aw :<C-u>call CustomWordMotion('gvaw')<CR>
" vnoremap iw :<C-u>call CustomWordMotion('gviw')<CR>
" 'W' inplace of the original 'w' (original 'W' is everything but whitespace, quite useless)
" nnoremap W w
" nnoremap daW daw
" nnoremap diW diw
" nnoremap dW dw
" nnoremap caW caw
" nnoremap ciW ciw
" nnoremap cW viwc
" vnoremap aW aw
" vnoremap iW iw

" inoremap <expr> <C-L> IsCursorAtEnd() ? "<Cmd>echo 'true'<CR> " : "<Cmd>echo 'false'<CR>"
" insert mode delete until word end
inoremap <expr> <C-e> IsCursorAtEnd() ? "<Del>" : IsCursorAtStart() ? "<Esc>ce" : "<Esc>lce"
" insert mode delete until word begining (excludes current cursor) redundant
" inoremap <expr> <C-w> IsCursorAtStart() ? "<BS>" : IsCursorAtEnd() ? "<Esc>cb<Del>" : "<Esc>lcb"
" insert mode delete current word
" inoremap <expr> <C-c> IsCursorAtLastWord() ? (col('.') == col('$') - 1 ? "<Esc>:set virtualedit=onemore<CR>llbdw:set virtualedit=<CR>xi" : "<Esc>llbdwxi") : "<Esc>llbdwi"
" imap <expr> <C-c> IsCursorAtStart() ? "<Esc>viwc" : IsCursorAtEnd() ? "<Esc>viwc" : "<Esc>lviwc"
imap <expr> <C-c> (IsCursorAtStart()\|\|IsCursorAtEnd()) ? "<Esc><F3>l<C-c>" : "<Esc><F3><C-c>"
" imap <expr> <C-x> IsCursorAtStart() ? "<Esc>viWc" : IsCursorAtEnd() ? "<Esc>viWc" : "<Esc>lviWc"
inoremap <expr> <C-x> (IsCursorAtStart()\|\|IsCursorAtEnd()) ? "<Esc><F3>lviwc" : "<Esc><F3>viwc"
" normal mode change current word
" nnoremap <expr> <C-c> IsCursorAtLastWord() ? (col('.') == col('$') - 1 ? ":set virtualedit=onemore<CR>lbdw:set virtualedit=<CR>xi" : "lbdwxi") : "lbdwi"
nnoremap <C-c> v<Esc><cmd>call CustomWordMotion('gviw')<CR>c
nnoremap <C-x> viwc
" abc_def
" normal mode delete current word
" nnoremap <expr> <C-D> IsCursorAtLastWord() ? (col('.') == col('$') - 1 ? ":set virtualedit=onemore<CR>lbdw:set virtualedit=<CR>x" : "lbdwx") : "lbdw"
nmap <C-D> viwd

" #############################
" movement
" tag jump
nnoremap <Tab> <cmd>TagbarJumpNext<CR>
nnoremap <S-Tab> <cmd>TagbarJumpPrev<CR>
vnoremap <Tab> <cmd>TagbarJumpNext<CR>mjgv`j
vnoremap <S-Tab> <cmd>TagbarJumpPrev<CR>mjgv`j

" nmap <Tab> ]]
" nmap <S-Tab> [[
" vmap <Tab> ]]
" vmap <S-Tab> [[

" remap capital HJKL to prevent accidental trigger
noremap <leader>j J
noremap <leader>k K
" preventing V > J/K accidentally trigger mappings
xnoremap <nowait> J j
xnoremap <nowait> K k

" smart jump - decrease travel length by 1/2 when rapidly reversing
" function! SmartJump_jumpnr(directionlen_varName, reset_timeoutlen=500, stuckBreakout_times=2)
"   let l:prev_directionlen_varName = 'smartJump_prev_' . a:directionlen_varName
"   let l:stuckBreakout_counter_varName = 'smartJump_breakoutCounter_' . a:directionlen_varName
"   if !exists(l:prev_directionlen_varName)
"     " g: ... etc is a dict to all existing variable, wtf
"     let g:[l:prev_directionlen_varName] = g:[a:directionlen_varName]
"   endif
"   if !exists(l:stuckBreakout_counter_varName)
"     let g:[l:stuckBreakout_counter_varName] = a:stuckBreakout_times
"   endif
"   " let l:prev_directionlen = g:[l:prev_directionlen_varName]
"   " let l:directionlen = g:[a:directionlen_varName]
"   if g:[l:prev_directionlen] == 0
    
"     return a:directionlen
"   endif
"   if Sign(a:directionlen) == l:prev_directionlen
"     return round(a:directionlen)
"   else
"     g:[a:prev_directionlen_varName] = a:directionlen
"     return round((a:directionlen + 1) / 2)
"   endif
" endfunction

let g:smartJump_half_lastJK = 0
let g:smartJump_intervals = [1, 2, 4, 7]
noremap <expr> J "<cmd>let g:smartJump_half_lastJK=2<CR>" . g:smartJump_intervals[3] . "gj"
noremap <expr> K "<cmd>let g:smartJump_half_lastJK=2<CR>" . g:smartJump_intervals[3] . "gk"
noremap <expr> j g:smartJump_half_lastJK <= 0 ? "gj" : "<cmd>let g:smartJump_half_lastJK-=1<CR>". g:smartJump_intervals[g:smartJump_half_lastJK] . "gj"
noremap <expr> k g:smartJump_half_lastJK <= 0 ? "gk" : "<cmd>let g:smartJump_half_lastJK-=1<CR>". g:smartJump_intervals[g:smartJump_half_lastJK] . "gk"
let g:smartJump_half_lastHL = 0 
noremap H 10h<cmd>let g:smartJump_half_lastHL=1<CR>
noremap L 10l<cmd>let g:smartJump_half_lastHL=1<CR>
noremap <expr> h g:smartJump_half_lastHL <= 0 ? "h" : "5h<cmd>let g:smartJump_half_lastHL-=1<CR>"
noremap <expr> l g:smartJump_half_lastHL <= 0 ? "l" : "5l<cmd>let g:smartJump_half_lastHL-=1<CR>"

" noremap J 7j<cmd>let g:smartJump_half_lastJK=1<CR>call ReltimeTimer('Smartjump_j', 500)<CR>
" noremap K 7k<cmd>let g:smartJump_half_lastJK=1<CR>call ReltimeTimer('Smartjump_k', 500)<CR>
" noremap <expr> j ReltimeTimer('Smartjump_j', 500) || g:smartJump_half_lastJK <= 0 ? "j" : "3j<cmd>let g:smartJump_half_lastJK-=1<CR>"
" noremap <expr> k ReltimeTimer('Smartjump_k', 500) || g:smartJump_half_lastJK <= 0 ? "k" : "3k<cmd>let g:smartJump_half_lastJK-=1<CR>"
" let g:smartJump_half_lastHL = 0 
" noremap H 10h<cmd>let g:smartJump_half_lastHL=1<CR>call ReltimeTimer('Smartjump_h', 500)<CR>
" noremap L 10l<cmd>let g:smartJump_half_lastHL=1<CR>call ReltimeTimer('Smartjump_l', 500)<CR>
" noremap <expr> h ReltimeTimer('Smartjump_h', 500) || g:smartJump_half_lastHL <= 0 ? "h" : "5h<cmd>let g:smartJump_half_lastHL-=1<CR>"
" noremap <expr> l ReltimeTimer('Smartjump_l', 500) || g:smartJump_half_lastHL <= 0 ? "l" : "5l<cmd>let g:smartJump_half_lastHL-=1<CR>"

" forward/backward one paragraph (separated by empty line)
noremap <C-j> }
noremap <C-k> {
" forward/backward several words
noremap <C-l> 3W
noremap <C-h> 3B

"keep visual mode after indent
vnoremap > >gv^
vnoremap < <gv^
" indent with one > <
nnoremap <nowait> > >>
nnoremap <nowait> < <<

" toggle number sidebar (for more easily tmux select)
let g:signcolumn_toggle_state = 'no'
" nnoremap <expr> <f2> ":set number! relativenumber!"
nnoremap <expr> <f2> &signcolumn == 'yes' ? ":set signcolumn=no number! relativenumber!<CR>" : ":set signcolumn=yes number! relativenumber!<CR>"


" openning register panel
" nnoremap <leader>r :reg<CR>

" replace default gd behaviour (if you want highlighing word under cursor, use *)
" !replaced by coc-definition
" nnoremap <expr> gd getline('.')[col('.') - 2 : col('.') + len(@/) - 2] == @/ ? "*<C-]>" : "*<C-]>n"
" cmap w!! w !sudo tee % > /dev/null

" Insert mode quick deletion
" imap <C-BS> <C-W>

" pasting terminal command history
command -nargs=* Histps read !history | cut -f4- -d' ' <args>



" cursor position helper
function! IsCursorAtLastWord()
    " Save the current cursor position
    let l:save_cursor = getpos(".")

    " Find the end of the current word and get the line number
    call search('\\>', 'ce')
    let l:end_of_word_line = line(".")

    " Find the end of the line and get the line number
    call search('$', 'ce')
    let l:end_of_line_line = line(".")

    " Restore the cursor position
    call setpos('.', l:save_cursor)

    " Compare the line numbers and return the result
    return l:end_of_word_line == l:end_of_line_line
endfunction

function! IsCursorAtStart()
    return col('.') == 1
endfunction

function! IsCursorAtEnd()
    return col('.') == col('$')
endfunction

" System call for state checking
function! SystemCall(cmd)
    call system(a:cmd)
    return v:shell_error == 0
endfunction


" Clipboard settingss
" Check if X11 is installed
"if SystemCall('dpkg -l | grep xorg > /dev/null 2>&1')
"    " echo "X11 is installed. adopted system clipboard"
"    "setting clipboard
"    set clipboard=unnamedplus
"    set clipboard+=unnamed
"    " Use the OS clipboard by default (on versions compiled with `+clipboard`)
"    " set clipboard=unnamed

"    " yanking to system clipboard
"    vnoremap Y "+y
"    noremap YY "+yy

"    noremap <nowait> p gp
"    noremap <nowait> P "+gp
"    noremap gp p
"    noremap gP "+p
"    vnoremap gP "+P
"    " pls reserve mm for this
"    vnoremap <nowait> p mmgPv`mo
"    vnoremap <nowait> P mm"+gPv`mo

"    " In visual mode, 'D' cuts the selection and puts it in the system clipboard
"    vnoremap D "+x
"    " In normal mode, 'DD' cuts the line and puts it in the system clipboard
"    nnoremap DD "+dd
"else
    " YDP store into vim unamed register, and vim-tmux-register plugin will sync them to tmux buffer
    " you can go into tmux, <Leader>b to :show-buffer and copy it down (in windows terminal, Enter also copies)
    " (because tmux select is recognized by the terminal unlike vim select)
    " echo "X11 is not installed. adopted empty clipboard (with tmux buffer sharing)"
    " yanking to system clipboard
    " vnoremap y ""y
    " vnoremap Y Y:let @0=@"<CR>:echo 'nani!?'<CR>
    " nnoremap y ""y
    " nnoremap YY Y:let @0=@"<CR>:echo "nani!?"<CR>
    " nnoremap yy "0yy


    " paste replacement should be pasted onto the block cursor (original P is paste on cursor)
    " paste replacement should be pasted onto the block cursor (original P is paste on cursor)
    " visual mode paste should select the pasted content
    " first, fix cursor position after paste (default is - to the end if pasting no linebreak, to the begining of the next line if pasting linebreaks)

  " reserver mp (mark paste) for this
  let b:PasteSelect_Visual_consecutivePaste = v:false
  function! PasteSelect(reg, pasteMethod)
    " let [_, curline, curcol, _] = getpos('.')
    if getregtype(a:reg) ==# 'V'
      execute 'normal! "' . a:reg . a:pasteMethod
      call feedkeys('`[V`]')
    elseif getregtype(a:reg)->match("\<c-v>") >= 0
      execute 'normal! "' . a:reg . a:pasteMethod
      call feedkeys("`[\<C-v>`]")
    else
      execute 'normal! "' . a:reg . a:pasteMethod
      call feedkeys('`[v`]')
    endif
    undojoin
    " let b:PasteSelect_Visual_lastVPasteRange = [[line("'["), col("'[")], [line("']"), col("']")]]
    let cmdAvoiding_autocmd = "let b:PasteSelect_Visual_consecutivePaste = v:true"
    call timer_start(1, {tid -> CMDFunc(cmdAvoiding_autocmd)})
  endfunction
  " function! CGTest()
  "   autocmd! CursorMoved * ++once echom "!?"
  " endfunction
  " nnoremap <c-g> <cmd>call CGTest()<CR>
  "       \ <cmd>echom 'a??'<CR>
  autocmd! CursorMoved,ModeChanged * let b:PasteSelect_Visual_consecutivePaste = v:false
  " autocmd! CursorMoved * let b:PasteSelect_Visual_consecutivePaste = v:true
  function! PasteSelect_Visual(reg, pasteMethod, direction)
  " direction v:true for backward, v:false for forward
    if !exists('b:PasteSelect_Visual_consecutivePaste')
      let b:PasteSelect_Visual_consecutivePaste = v:false
    endif
    echom "# " . b:PasteSelect_Visual_consecutivePaste
    if b:PasteSelect_Visual_consecutivePaste
      " exec "normal! \<Esc>"
      call feedkeys("\<Esc>")
      call cursor(a:direction ? [line("'["), col("'[")] : [line("']"), col("']")])
      " a hack... there must be something not being resolved until the function ends
      call timer_start(1, {tid -> PasteSelect(a:reg, a:pasteMethod)})
    else
      call PasteSelect(a:reg, a:pasteMethod)
    endif
  endfunction

  vnoremap Y ygv
  vnoremap y ygv
  nnoremap P <cmd>call PasteSelect('0', 'p')<CR>
  nnoremap p <cmd>call PasteSelect('"', 'p')<CR>
  vnoremap P <cmd>call PasteSelect_Visual('0', 'p', 0)<CR>
  vnoremap p <cmd>call PasteSelect_Visual('"', 'p', 0)<CR>
  " turn gp (default: past and move to the end), into paste prior to cursor (originally P)
  " because original include/exclude motion can be replaced by alt-leave visual to either end (see <A-hjkl> mapping)
  nnoremap gP <cmd>call PasteSelect('0', 'P')<CR>
  nnoremap gp <cmd>call pasteSelect('"', 'P')<CR>
  vnoremap gP <cmd>call PasteSelect_Visual('0', 'P', 1)<CR>
  vnoremap gp <cmd>call PasteSelect_Visual('"', 'P', 1)<CR>
  " unmap p
  " unmap P

  " voremap d ""d
  vnoremap D "0d
  " nnoremap d ""d
  nnoremap D "0d
  nnoremap DD "0dd
  " nnoremap dd "0dd

" endif
" 6/28/2024, dunno why but the SystemCall check suddenly passed without X11, disabling it
" custom host yank support
let s:clipboard_export = '/mnt/c/clipboard.txt'  " change this path according to your mount point
" let s:clipboard_import = '/mnt/c/clipboard.txt'  " change this path according to your mount point
function! ExportClipboard(text)
  call writefile(split(a:text, '\(\n\|\n\r\)', 1), s:clipboard_export, 'b')
endfunction
if filereadable(s:clipboard_export)
  augroup WSLYank
    autocmd!
    " WSL
    " autocmd TextYankPost * if v:event.operator ==# 'y' | call system('echo ' . shellescape(@0) . ' > ' . s:clipboard_export) | endif
    " autocmd TextYankPost * if v:event.operator =~# 'y' | call system('echo ' . shellescape(substitute(@0, '\n$', '', '')) . ' > ' . s:clipboard_export) | endif
    " to deal with '\0' literal, using echo will just interpret it as NULL character
    autocmd TextYankPost * if v:event.operator =~# '\(d\|y\)' | call ExportClipboard(@0) | endif
    " autocmd TextYankPost * if v:event.operator =~# 'y' | echo 'bababooboo' . s:clipboard_export | endif
  augroup END
endif


" matching 0 as line start, - as line end
nnoremap - $
" operator pending mode
onoremap - $

" disable command-line window binding
nnoremap <nowait> q: <Nop>
nnoremap Q <Nop>

nnoremap o o<Esc>==
nnoremap O O<Esc>==

" this is how you map alt-key ! turning it into a proper keycode that vim can interpret (quick succession of the code within ttimeoutlen)
" noted, the ^[ is not literal, you need to i_<C-q> + <Esc> to type it out
set <M-o>=o
" this doesn't work because f1~f3 keycode starts with O
" , so keycode for <alt-shift-o>==O will be pending and not interpreted
" set <M-O>=O
" from your terminal (if you can) modify <alt-shift-o> to send a self-defined keycode
" e.g. Windows terminal ("\u001b" == ) :
" {"command": {"action": "sendInput","input": "\u001bOO"}, "keys": "alt+shift+o"}
" see "ANSI control sequence (specifically - introducer command)"
" https://en.wikipedia.org/wiki/ANSI_escape_code
set <M-O>=OO

inoremap <M-o> <C-o>o<C-o>==
inoremap <M-O> <C-o>O<C-o>==
" inoremap <M-O> <cmd>echom "asda"<CR>

" a hack, I believe it works without affecting alt-o because alt-key escape combo is counted towards ttimeout (it's a key sequence), and ttimeout is set
" inoremap <nowait> <Esc> <Esc>
" insert mode add newline, can't map <Esc>o/O because it'll interfere with insert arrow keys below
" inoremap <nowait> ^]o <Esc>o
" inoremap <nowait> ^]O <Esc>O
" inoremap <nowait> ^[o <Esc>o
" inoremap <nowait> ^[O <Esc>O
" replace default arrow key to avoid escape sequence conflict (arrow keys will
" be translated into Esc+... and triggering "insert mode add newline" defined
" above)
" function! MiscMap_insertUp()
"   let [curline, curcol] = [line('.'), col('.')]
"   call cursor([l:curline-1, l:curcol])
" endfunction
" function! MiscMap_insertDown()
"   let [curline, curcol] = [line('.'), col('.')]
"   call cursor([l:curline+1, l:curcol])
" endfunction
function! MiscMap_insertLeft()
  let [curline, curcol] = [line('.'), col('.')]
  if l:curcol <= 1 && l:curline > 1
    call cursor([l:curline-1, 1])
    call cursor([l:curline-1, col('$')])
  else
    call cursor([l:curline, l:curcol-1])
  endif
endfunction
function! MiscMap_insertRight()
  let [curline, curcol] = [line('.'), col('.')]
  if l:curcol >= col('$') && l:curline < line('$')
    call cursor([l:curline+1, 1])
  else
    call cursor([l:curline, l:curcol+1])
  endif
endfunction
" inoremap <nowait> <Up> <cmd>let miscMap_UpOption=&startofline\|set nostartofline\|normal! gk\|let &startofline=miscMap_UpOption<CR>
inoremap <nowait> <Up> <cmd>normal! gk<CR>
inoremap <nowait> <Down> <cmd>normal! gj<CR>
inoremap <nowait> <Left> <cmd>call MiscMap_insertLeft()<CR>
inoremap <nowait> <Right> <cmd>call MiscMap_insertRight()<CR>
" inoremap <expr> <nowait> <Up> col(".") == 1 ? "<Esc>ki" : "<Esc>ka"
" inoremap <expr> <nowait> <Down> col(".") == 1 ? "<Esc>ji" : "<Esc>ja"
" inoremap <expr> <nowait> <Left> col(".") == 1 ? "<Esc>k$a" : "<Esc>i"
" inoremap <expr> <nowait> <Right> col(".") == col("$") ? "<Esc>j0i" : (col(".") == 1 ? "<Esc>li" : "<Esc>la")

" same in normal mode
nnoremap <nowait> <Up> gk
nnoremap <nowait> <Down> gj
nnoremap <expr> <nowait> <Left> col(".") == 1 ? "k$" : "h"
nnoremap <expr> <nowait> <Right> col(".") == col("$") - 1 ? "j0" : col(".") == col("$") ? "j0" : "l"


" XXX reserve <f3> to be an "do nothing" key for breaking up mappings/feedkeys()/:normal keys triggerring other mappings/keycode (only for non-nore mapping, event keycode won't be triggerred by noremap)
" inoremap <F3> <nop>
nnoremap <F3> <nop>

" increment/decrement alternatives
nnoremap gi <C-a>
nnoremap gx <C-x>

" insert mode indent
inoremap <C-\> <C-T>
" insert mode deindent
" don't bind <C-[>, it'll capture any escape sequence and you can never leave insert mode...
inoremap <C-]> <C-D>
" insert mode keyword completion replace C-p with C -m
" inoremap <C-m> <C-p>
" insert mode paste from register ("" register from y)
" inoremap <C-p> <C-r>"


noremap <C-Up> <C-Y>
noremap <C-Down> <C-E>

function! OpenTempBuffer_empty(open_command='vnew +call\ ResizeVertical(30)')
  execute a:open_command
  setlocal buftype=nofile bufhidden=delete " set delete buffer after exiting
  setlocal nowrap
  setlocal noswapfile
  nnoremap <nowait> <buffer> q :bd<CR>
endfunction

" ,m to open mapping buffer
function! OpenTempBuffer_fromOutput(output_command, open_command=v:none, sortCMD='')
  let old_reg = getreg("a")          " save the current content of register a
  let old_reg_type = getregtype("a") " save the type of the register as well
  try
    redir @a                           " redirect output to register a
    " Get the list of all key mappings silently, satisfy "Press ENTER to continue"
    silent execute a:output_command | call feedkeys("\<CR>")
    redir END                          " end output redirection
    " vnew                               " new buffer in vertical window
    call OpenTempBuffer_empty(a:open_command)
    put a                              " put content of register
    execute a:sortCMD
    setlocal nomodifiable
  finally                              " Execute even if exception is raised
    call setreg("a", old_reg, old_reg_type) " restore register a
  "trying to replace :q in the mapping pane with :bd | q for clearing buffer
  endtry
endfunction
" open mapping buffer
nnoremap <leader>mm :call OpenTempBuffer_fromOutput('map', v:none, '%!sort -k1.4,1.4')<CR>

function! OpenTempBuffer_fromCommand(load_command, open_command)
  call OpenTempBuffer_empty(a:open_command)
  execute a:load_command
  setlocal nomodifiable
endfunction
" openup the full highlight document
" open highlight buffer
" TODO fix the temp buffer configuration not working on this load command
command! Highlight call OpenTempBuffer_fromCommand('so $VIMRUNTIME/syntax/hitest.vim', 'tabnew')

" Strip trailing whitespace (,sw)
function! StripWhitespace()
	let save_cursor = getpos(".")
	let old_query = getreg('/')
	:%s/\s\+$//e
	call setpos('.', save_cursor)
	call setreg('/', old_query)
endfunction
noremap <leader>ws :call StripWhitespace()<CR>
" Save a file as root (,W)
noremap <leader>W :w !sudo tee % > /dev/null<CR>

" :reload vim
" command R source ~/.vimrc