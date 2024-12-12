" #===================================================================================#


" map nnoremap r to macro recording (q), because r replacement mode single replace is useless (R line replace is still there)
if maparg('q', 'n')==''
  nnoremap q <nop>
  nnoremap <nowait> q <cmd>echo "q recording remapped to r"<CR>
endif
nnoremap r q

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
noremap <A-k> <Esc>k
noremap <A-j> <Esc>j
noremap <A-h> <Esc>h
noremap <A-l> <Esc>l
inoremap <A-k> <Esc>k
inoremap <A-j> <Esc>j
inoremap <A-h> <Esc>h
inoremap <A-l> <Esc>l
cnoremap <expr> <A-k> getcmdtype()=='/' \|\| getcmdtype()=='?' ? "<CR>``" : "<CR>"
cnoremap <expr> <A-j> getcmdtype()=='/' \|\| getcmdtype()=='?' ? "<CR>``" : "<CR>"
cnoremap <expr> <A-h> getcmdtype()=='/' \|\| getcmdtype()=='?' ? "<CR>``" : "<CR>"
cnoremap <expr> <A-l> getcmdtype()=='/' \|\| getcmdtype()=='?' ? "<CR>``" : "<CR>"


" mouse click for displaying synID
nnoremap <leftmouse> <leftmouse>:echo "synID(line=" . line('.') . ", col=" . col('.') .  ") = " . synID(line('.'), col('.'), 0)<CR>

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
  execute "TabDrop Man " . l:text
  " disable special character display
  execute "setlocal nolist"
  " replaced inside ~/.vim/ftplugin
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
  silent call TabDropCMD("help " . l:text)
  " execute "tab help " . l:text
  execute "tag /" . l:text
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
    let l:line_before = line("$")
    execute "read !ctags --fields=+S -x --c-kinds=f " . shellescape(a:file) . " | awk '{sub(/\{/, \"\", $0); print substr($0, index($0,$5))}'"
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

" space based mapping
nnoremap <space><space> i<space><Esc>la<space><Esc>h
vnoremap <space><space> <esc>`<i<space><Esc>`>la<space><Esc>`<lv`>l
nnoremap <space>d f<space>xF<space>x
vnoremap <space>d <esc>`>f<space>x`<F<space>x`<hv`>h

" mapping yh
function! ConfirmAndAppend(match)
    " Ask the user if they want to append the match to the register
    " if confirm("Append this match to register a? " . a:match, "&Yes\n&No") == 1
    call setreg('0', a:match . "\n", 'a')
    " endif
    return a:match  " Replace the match with itself
endfunction
" save all matching into register separated by \n
nnoremap yh :let @0=''<CR>:%s//\=ConfirmAndAppend(submatch(0))/c<CR>doautocmd WSLYank TextYankPost<CR>
nnoremap yh :let @0=''<CR>:%s/\v(\_.+)/\=ConfirmAndAppend(submatch(0))/gn<CR>doautocmd WSLYank TextYankPost<CR>

" search pattern pre-fill
" reserve s register for matched text
" nnoremap ;; :%s:::c<C-b><right><right><right>
" nnoremap ;' :%s:::n<C-b><right><right><right>
" vnoremap ;; <Esc>:'<,'>s:\%V::c<C-b><right><right><right><right><right><right><right><right><right><right>
" vnoremap ;' <Esc>:'<,'>s:\%V::n<C-b><right><right><right><right><right><right><right><right><right><right>

" search in recently selected lines
nnoremap <leader>/ /\%V
vnoremap <leader>/ <Esc>/\%V

" mapping C-w + C-hjkl for pane-enlarging switch
function! ResizeVertical(percent)
    execute 'vertical resize'
    let l:current_width = winwidth(0)
    let l:resize_amount = float2nr(l:current_width * a:percent / 100)
    execute 'vertical resize ' . l:resize_amount
endfunction
function! ResizeHorizontal(percent)
    execute 'resize'
    let l:current_height = winheight(0)
    let l:resize_amount = float2nr(l:current_height * a:percent / 100)
    execute 'resize ' . resize_amount
endfunction
" Resize mappings with Ctrl held down
nnoremap <C-w><C-h> :wincmd h<CR>:call ResizeVertical(75)<CR>
nnoremap <C-w><C-j> :wincmd j<CR>:call ResizeHorizontal(75)<CR>
nnoremap <C-w><C-k> :wincmd k<CR>:call ResizeHorizontal(75)<CR>
nnoremap <C-w><C-l> :wincmd l<CR>:call ResizeVertical(75)<CR>


" ========================================================================="
" Buffer Related Actions
" Store cursor and scroll position when leaving a buffer
augroup BufferActions
  autocmd!
  autocmd BufLeave * let b:most_recent_buffer_topline = line('w0')
  " autocmd BufEnter * let b:most_recent_buffer_topline = 0
  autocmd BufEnter * if !exists('b:most_recent_buffer_topline') | let b:most_recent_buffer_topline = 0 | endif
augroup END

function! BufferActions_restoreScrollPosition()
  execute "normal! zt"
  let l:offset = b:most_recent_buffer_topline - line('w0')
  if(l:offset == 0)
    return
  endif
  if(l:offset < 0)
    execute "normal! " . -l:offset . "\<C-Y>"
  else
    execute "normal! " . l:offset . "\<C-E>"
  endif
endfunction

" next/prev buffer
noremap <c-b>n :bn \| call BufferActions_restoreScrollPosition()<CR>
noremap <c-b>N :bp \| call BufferActions_restoreScrollPosition()<CR>
noremap <C-b>p :b# \| call BufferActions_restoreScrollPosition()<CR>
" return true; open cuurent buffer into new tab
nnoremap <C-b>t :tab split \| call BufferActions_restoreScrollPosition()<CR>
nnoremap <C-b>a :tab sball<CR>
" unload current buffer
nnoremap <C-b>d :bd<CR>

" ========================================================================="

" Keybinding Mappings
inoremap <C-k> <C-o>d$
inoremap <C-b> <C-o>d^

" crude auto indent
" imap <expr> <Tab> (col('.') == 1) && (getline(line('.')-1) != '') ? '<C-w><CR><C-o>:if col(".") == 1 \| call feedkeys("\t", "n") \| endif<CR>' : '<Plug>CocNextCompletionCustom'

" undo line with <leader>ul
nnoremap <leader>ul U
nnoremap U <C-r>

" selection replacement
function! ReplaceWithInput() abort
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
  let l:replacement_text = escape(l:replacement_text, '\/.^$*[]~')
  " cursor to end + start to cursor - faulty, cuz the first highlight will most certainly be skipped
  
  let l:firstHalf_start = [l:cusline, l:cuscol]
  let l:firstHalf_end = [line('$'), col([line('$'), '$'])]
  let l:pattern_firstHalf = RangedPattern(l:firstHalf_start, l:firstHalf_end, @h)
  " echom "%s/" . l:pattern_firstHalf ."//ce"
  execute "%s/" . l:pattern_firstHalf ."/" . l:replacement_text . "/ce"
  " execute '.,$s/' . '\%>' . (l:cusline-1) . 'l' . l:old_pattern . '/' . l:replacement_text . '/ce'
  echo 'wrapped around EOF'
  let l:secondHalf_start = [1, 1]
  let l:secondHalf_end = l:cuscol <= 1 ? [l:cusline - 1, col([line('$') - 1, '$'])] : [l:cusline, l:cuscol - 1]
  let l:pattern_secondHalf = RangedPattern(l:secondHalf_start, l:secondHalf_end, @h)
  " echom "%s/" . l:pattern_secondHalf ."//ce"
  execute "%s/" . l:pattern_secondHalf ."/" . l:replacement_text . "/ce"
  " execute '1,' . l:cusline . 's/' . l:old_pattern . '/' . l:replacement_text . '/ce'
endfunction
vnoremap <silent> <C-r> "hy:<C-u>silent call ReplaceWithinput()<CR>
" if cursor on top of match highlights, enter replacing commands
" nnoremap <expr> <C-r> IsOnMatch() ? ':call search(@/, "cb")<CR>v//e<CR>"hy:<C-u>call ReplaceWithInput()<CR>' : '<C-r>'
" matching replacement with @/ stored inside @h instead of copy the first match literally as the pattern
nnoremap <silent> <expr> <C-r> IsOnMatch() ? ':let @h=@/<CR>:call ReplaceWithInput()<CR>' : '<C-r>'

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
nmap <silent> <C-n> <Plug>VerityHighlightNext_N
vmap <silent> <C-n> <Plug>VerityHighlightNext_V
nmap <silent> <C-p> <Plug>VerityHighlightPrev_N
vmap <silent> <C-p> <Plug>VerityHighlightPrev_V

" visual to the end don't enclude newline
vnoremap _ $
vnoremap - $h


" two way expansion of visual selection
vnoremap L <Esc>`<v`>loho
vnoremap H <Esc>`<v`>holo


" C-u C-r in insert mode for undo/redo
inoremap <C-u> <C-o>u
inoremap <C-r> <C-o><C-r>

" change 'w' word motion behaviour to excludes '_'
function! CustomWordMotion(cmd)
    let old_iskeyword=&iskeyword
    set iskeyword-=_
    execute "normal! " . a:cmd
    let &iskeyword=old_iskeyword
endfunction

nnoremap w :call CustomWordMotion('w')<CR>
nnoremap daw :call CustomWordMotion('daw')<CR>
nnoremap diw :call CustomWordMotion('diw')<CR>
" use visual mode to change word is because command will exit insert mode
" recursively linked to aw/iw below
nmap caw vawc
nmap ciw viwc
nmap cw viwc
nmap daw vawd
nmap diw viwd
nmap dw viwd
vnoremap aw :<C-u>call CustomWordMotion('gvaw')<CR>
vnoremap iw :<C-u>call CustomWordMotion('gviw')<CR>
" 'W' inplace of the original 'w' (original 'W' is everything but whitespace, quite useless)
nnoremap W w
nnoremap daW daw
nnoremap diW diw
nnoremap dW dw
nnoremap caW caw
nnoremap ciW ciw
nnoremap cW viwc
vnoremap aW aw
vnoremap iW iw

" #############################
" movement
" tag jump
nnoremap <Tab> <cmd>TagbarJumpNext<CR>
nnoremap <S-Tab> <cmd>TagbarJumpPrev<CR>

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
noremap J 7j<cmd>let g:smartJump_half_lastJK=1<CR>
noremap K 7k<cmd>let g:smartJump_half_lastJK=1<CR>
noremap <expr> j g:smartJump_half_lastJK <= 0 ? "j" : "3j<cmd>let g:smartJump_half_lastJK-=1<CR>"
noremap <expr> k g:smartJump_half_lastJK <= 0 ? "k" : "3k<cmd>let g:smartJump_half_lastJK-=1<CR>"
let g:smartJump_half_lastHL = 0 
noremap H 10h<cmd>let g:smartJump_half_lastHL=1<CR>
noremap L 10l<cmd>let g:smartJump_half_lastHL=1<CR>
noremap <expr> h g:smartJump_half_lastHL <= 0 ? "h" : "5h<cmd>let g:smartJump_half_lastHL-=1<CR>"
" #===================================================================================#


" map nnoremap r to macro recording (q), because r replacement mode single replace is useless (R line replace is still there)
if maparg('q', 'n')==''
  nnoremap q <nop>
  nnoremap <nowait> q <cmd>echo "q recording remapped to r"<CR>
endif
nnoremap r q

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
noremap <A-k> <Esc>k
noremap <A-j> <Esc>j
noremap <A-h> <Esc>h
noremap <A-l> <Esc>l
inoremap <A-k> <Esc>k
inoremap <A-j> <Esc>j
inoremap <A-h> <Esc>h
inoremap <A-l> <Esc>l
cnoremap <expr> <A-k> getcmdtype()=='/' \|\| getcmdtype()=='?' ? "<CR>``" : "<CR>"
cnoremap <expr> <A-j> getcmdtype()=='/' \|\| getcmdtype()=='?' ? "<CR>``" : "<CR>"
cnoremap <expr> <A-h> getcmdtype()=='/' \|\| getcmdtype()=='?' ? "<CR>``" : "<CR>"
cnoremap <expr> <A-l> getcmdtype()=='/' \|\| getcmdtype()=='?' ? "<CR>``" : "<CR>"


" mouse click for displaying synID
nnoremap <leftmouse> <leftmouse>:echo "synID(line=" . line('.') . ", col=" . col('.') .  ") = " . synID(line('.'), col('.'), 0)<CR>

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
  execute "TabDrop Man " . l:text
  " disable special character display
  execute "setlocal nolist"
  " replaced inside ~/.vim/ftplugin
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
  silent call TabDropCMD("help " . l:text)
  " execute "tab help " . l:text
  execute "tag /" . l:text
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
    let l:line_before = line("$")
    execute "read !ctags --fields=+S -x --c-kinds=f " . shellescape(a:file) . " | awk '{sub(/\{/, \"\", $0); print substr($0, index($0,$5))}'"
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

" space based mapping
nnoremap <space><space> i<space><Esc>la<space><Esc>h
vnoremap <space><space> <esc>`<i<space><Esc>`>la<space><Esc>`<lv`>l
nnoremap <space>d f<space>xF<space>x
vnoremap <space>d <esc>`>f<space>x`<F<space>x`<hv`>h

" mapping yh
function! ConfirmAndAppend(match)
    " Ask the user if they want to append the match to the register
    " if confirm("Append this match to register a? " . a:match, "&Yes\n&No") == 1
    call setreg('0', a:match . "\n", 'a')
    " endif
    return a:match  " Replace the match with itself
endfunction
" save all matching into register separated by \n
nnoremap yh :let @0=''<CR>:%s//\=ConfirmAndAppend(submatch(0))/c<CR>doautocmd WSLYank TextYankPost<CR>
nnoremap yh :let @0=''<CR>:%s/\v(\_.+)/\=ConfirmAndAppend(submatch(0))/gn<CR>doautocmd WSLYank TextYankPost<CR>

" search pattern pre-fill
" reserve s register for matched text
" nnoremap ;; :%s:::c<C-b><right><right><right>
" nnoremap ;' :%s:::n<C-b><right><right><right>
" vnoremap ;; <Esc>:'<,'>s:\%V::c<C-b><right><right><right><right><right><right><right><right><right><right>
" vnoremap ;' <Esc>:'<,'>s:\%V::n<C-b><right><right><right><right><right><right><right><right><right><right>

" search in recently selected lines
nnoremap <leader>/ /\%V
vnoremap <leader>/ <Esc>/\%V

" mapping C-w + C-hjkl for pane-enlarging switch
function! ResizeVertical(percent)
    execute 'vertical resize'
    let l:current_width = winwidth(0)
    let l:resize_amount = float2nr(l:current_width * a:percent / 100)
    execute 'vertical resize ' . l:resize_amount
endfunction
function! ResizeHorizontal(percent)
    execute 'resize'
    let l:current_height = winheight(0)
    let l:resize_amount = float2nr(l:current_height * a:percent / 100)
    execute 'resize ' . resize_amount
endfunction
" Resize mappings with Ctrl held down
nnoremap <C-w><C-h> :wincmd h<CR>:call ResizeVertical(75)<CR>
nnoremap <C-w><C-j> :wincmd j<CR>:call ResizeHorizontal(75)<CR>
nnoremap <C-w><C-k> :wincmd k<CR>:call ResizeHorizontal(75)<CR>
nnoremap <C-w><C-l> :wincmd l<CR>:call ResizeVertical(75)<CR>


" ========================================================================="
" Buffer Related Actions
" Store cursor and scroll position when leaving a buffer
augroup BufferActions
  autocmd!
  autocmd BufLeave * let b:most_recent_buffer_topline = line('w0')
  " autocmd BufEnter * let b:most_recent_buffer_topline = 0
  autocmd BufEnter * if !exists('b:most_recent_buffer_topline') | let b:most_recent_buffer_topline = 0 | endif
augroup END

function! BufferActions_restoreScrollPosition()
  execute "normal! zt"
  let l:offset = b:most_recent_buffer_topline - line('w0')
  if(l:offset == 0)
    return
  endif
  if(l:offset < 0)
    execute "normal! " . -l:offset . "\<C-Y>"
  else
    execute "normal! " . l:offset . "\<C-E>"
  endif
endfunction

" next/prev buffer
noremap <c-b>n :bn \| call BufferActions_restoreScrollPosition()<CR>
noremap <c-b>N :bp \| call BufferActions_restoreScrollPosition()<CR>
noremap <C-b>p :b# \| call BufferActions_restoreScrollPosition()<CR>
" return true; open cuurent buffer into new tab
nnoremap <C-b>t :tab split \| call BufferActions_restoreScrollPosition()<CR>
nnoremap <C-b>a :tab sball<CR>
" unload current buffer
nnoremap <C-b>d :bd<CR>

" ========================================================================="

" Keybinding Mappings
inoremap <C-k> <C-o>d$
inoremap <C-b> <C-o>d^

" crude auto indent
" imap <expr> <Tab> (col('.') == 1) && (getline(line('.')-1) != '') ? '<C-w><CR><C-o>:if col(".") == 1 \| call feedkeys("\t", "n") \| endif<CR>' : '<Plug>CocNextCompletionCustom'

" undo line with <leader>ul
nnoremap <leader>ul U
nnoremap U <C-r>

" selection replacement
function! ReplaceWithInput() abort
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
  let l:replacement_text = escape(l:replacement_text, '\/.^$*[]~')
  " cursor to end + start to cursor - faulty, cuz the first highlight will most certainly be skipped
  
  let l:firstHalf_start = [l:cusline, l:cuscol]
  let l:firstHalf_end = [line('$'), col([line('$'), '$'])]
  let l:pattern_firstHalf = RangedPattern(l:firstHalf_start, l:firstHalf_end, @h)
  " echom "%s/" . l:pattern_firstHalf ."//ce"
  execute "%s/" . l:pattern_firstHalf ."/" . l:replacement_text . "/ce"
  " execute '.,$s/' . '\%>' . (l:cusline-1) . 'l' . l:old_pattern . '/' . l:replacement_text . '/ce'
  echo 'wrapped around EOF'
  let l:secondHalf_start = [1, 1]
  let l:secondHalf_end = l:cuscol <= 1 ? [l:cusline - 1, col([line('$') - 1, '$'])] : [l:cusline, l:cuscol - 1]
  let l:pattern_secondHalf = RangedPattern(l:secondHalf_start, l:secondHalf_end, @h)
  " echom "%s/" . l:pattern_secondHalf ."//ce"
  execute "%s/" . l:pattern_secondHalf ."/" . l:replacement_text . "/ce"
  " execute '1,' . l:cusline . 's/' . l:old_pattern . '/' . l:replacement_text . '/ce'
endfunction
vnoremap <silent> <C-r> "hy:<C-u>silent call ReplaceWithinput()<CR>
" if cursor on top of match highlights, enter replacing commands
" nnoremap <expr> <C-r> IsOnMatch() ? ':call search(@/, "cb")<CR>v//e<CR>"hy:<C-u>call ReplaceWithInput()<CR>' : '<C-r>'
" matching replacement with @/ stored inside @h instead of copy the first match literally as the pattern
nnoremap <silent> <expr> <C-r> IsOnMatch() ? ':let @h=@/<CR>:call ReplaceWithInput()<CR>' : '<C-r>'

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
nmap <silent> <C-n> <Plug>VerityHighlightNext_N
vmap <silent> <C-n> <Plug>VerityHighlightNext_V
nmap <silent> <C-p> <Plug>VerityHighlightPrev_N
vmap <silent> <C-p> <Plug>VerityHighlightPrev_V

" visual to the end don't enclude newline
vnoremap _ $
vnoremap - $h


" two way expansion of visual selection
vnoremap L <Esc>`<v`>loho
vnoremap H <Esc>`<v`>holo


" C-u C-r in insert mode for undo/redo
inoremap <C-u> <C-o>u
inoremap <C-r> <C-o><C-r>

" change 'w' word motion behaviour to excludes '_'
function! CustomWordMotion(cmd)
    let old_iskeyword=&iskeyword
    set iskeyword-=_
    execute "normal! " . a:cmd
    let &iskeyword=old_iskeyword
endfunction

nnoremap w :call CustomWordMotion('w')<CR>
nnoremap daw :call CustomWordMotion('daw')<CR>
nnoremap diw :call CustomWordMotion('diw')<CR>
" use visual mode to change word is because command will exit insert mode
" recursively linked to aw/iw below
nmap caw vawc
nmap ciw viwc
nmap cw viwc
nmap daw vawd
nmap diw viwd
nmap dw viwd
vnoremap aw :<C-u>call CustomWordMotion('gvaw')<CR>
vnoremap iw :<C-u>call CustomWordMotion('gviw')<CR>
" 'W' inplace of the original 'w' (original 'W' is everything but whitespace, quite useless)
nnoremap W w
nnoremap daW daw
nnoremap diW diw
nnoremap dW dw
nnoremap caW caw
nnoremap ciW ciw
nnoremap cW viwc
vnoremap aW aw
vnoremap iW iw

" #############################
" movement
" tag jump
nnoremap <Tab> <cmd>TagbarJumpNext<CR>
nnoremap <S-Tab> <cmd>TagbarJumpPrev<CR>

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
noremap J 7j<cmd>let g:smartJump_half_lastJK=1<CR>
noremap K 7k<cmd>let g:smartJump_half_lastJK=1<CR>
noremap <expr> j g:smartJump_half_lastJK <= 0 ? "j" : "3j<cmd>let g:smartJump_half_lastJK-=1<CR>"
noremap <expr> k g:smartJump_half_lastJK <= 0 ? "k" : "3k<cmd>let g:smartJump_half_lastJK-=1<CR>"
let g:smartJump_half_lastHL = 0 
noremap H 10h<cmd>let g:smartJump_half_lastHL=1<CR>
noremap L 10l<cmd>let g:smartJump_half_lastHL=1<CR>
noremap <expr> h g:smartJump_half_lastHL <= 0 ? "h" : "5h<cmd>let g:smartJump_half_lastHL-=1<CR>"
noremap <expr> l g:smartJump_half_lastHL <= 0 ? "l" : "5l<cmd>let g:smartJump_half_lastHL-=1<CR>"

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


cmap w!! w !sudo tee % > /dev/null

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
    " visual mode paste should select the pasted content
    " first, fix cursor position after paste (default is - to the end if pasting no linebreak, to the begining of the next line if pasting linebreaks)

    nnoremap <nowait> P "0P
    " vnoremap <nowait> p "0p
    vnoremap <nowait> P "0P
    " nnoremap gp "0gp
    nnoremap gP "0gP
    " pls reserve mp for this
    " vnoremap <nowait> gp  mp"0pv`po
    vnoremap <nowait> gP  mp"0Pv`po

    " voremap d ""d
    vnoremap D "0d
    " nnoremap d ""d
    nnoremap D "0dd
    " nnoremap dd "0dd

" endif
" 6/28/2024, dunno why but the SystemCall check suddenly passed without X11, disabling it

" custom host yank support
let s:clipboard_export = '/mnt/c/clipboard.txt'  " change this path according to your mount point
if filereadable(s:clipboard_export)
  augroup WSLYank
    autocmd!
    " WSL
    " autocmd TextYankPost * if v:event.operator ==# 'y' | call system('echo ' . shellescape(@0) . ' > ' . s:clipboard_export) | endif
    " autocmd TextYankPost * if v:event.operator =~# 'y' | call system('echo ' . shellescape(substitute(@0, '\n$', '', '')) . ' > ' . s:clipboard_export) | endif
    " to deal with '\0' literal, using echo will just interpret it as NULL character
    autocmd TextYankPost * if v:event.operator =~# '\(d\|y\)' | call writefile(split(@0, '\(\n\|\n\r\)', 1), s:clipboard_export, 'b') | endif
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
set <A-o>=o
set <A-O>=*O
inoremap <A-o> <C-o>o<C-o>==
inoremap <A-O> <C-o>O<C-o>==

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
inoremap <expr> <nowait> <Up> col(".") == 1 ? "<Esc>ki" : "<Esc>ka"
inoremap <expr> <nowait> <Down> col(".") == 1 ? "<Esc>ji" : "<Esc>ja"
inoremap <expr> <nowait> <Left> col(".") == 1 ? "<Esc>k$a" : "<Esc>i"
inoremap <expr> <nowait> <Right> col(".") == col("$") ? "<Esc>j0i" : (col(".") == 1 ? "<Esc>li" : "<Esc>la")

" same in normal mode
nnoremap <nowait> <Up> k
nnoremap <nowait> <Down> j
nnoremap <expr> <nowait> <Left> col(".") == 1 ? "k$" : "h"
nnoremap <expr> <nowait> <Right> col(".") == col("$") - 1 ? "j0" : col(".") == col("$") ? "j0" : "l"

" inoremap <expr> <C-L> IsCursorAtEnd() ? "<Cmd>echo 'true'<CR> " : "<Cmd>echo 'false'<CR>"
" insert mode delete until word end
inoremap <expr> <C-e> IsCursorAtEnd() ? "<Del>" : IsCursorAtStart() ? "<Esc>ce" : "<Esc>lce"
" insert mode delete until word begining (excludes current cursor) redundant
" inoremap <expr> <C-w> IsCursorAtStart() ? "<BS>" : IsCursorAtEnd() ? "<Esc>cb<Del>" : "<Esc>lcb"
" insert mode delete current word
" inoremap <expr> <C-c> IsCursorAtLastWord() ? (col('.') == col('$') - 1 ? "<Esc>:set virtualedit=onemore<CR>llbdw:set virtualedit=<CR>xi" : "<Esc>llbdwxi") : "<Esc>llbdwi"
imap <expr> <C-c> IsCursorAtStart() ? "<Esc>viwc" : IsCursorAtEnd() ? "<Esc>viwc" : "<Esc>lviwc"
imap <expr> <C-x> IsCursorAtStart() ? "<Esc>viWc" : IsCursorAtEnd() ? "<Esc>viWc" : "<Esc>lviWc"
" normal mode change current word
" nnoremap <expr> <C-c> IsCursorAtLastWord() ? (col('.') == col('$') - 1 ? ":set virtualedit=onemore<CR>lbdw:set virtualedit=<CR>xi" : "lbdwxi") : "lbdwi"
nmap <C-c> viwc
nmap <C-x> viWc

" increment/decrement alternatives
nnoremap gi <C-a>
nnoremap gx <C-x>

" normal mode delete current word
" nnoremap <expr> <C-D> IsCursorAtLastWord() ? (col('.') == col('$') - 1 ? ":set virtualedit=onemore<CR>lbdw:set virtualedit=<CR>x" : "lbdwx") : "lbdw"
nmap <C-D> viWd

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
command R source ~/.vimrc
noremap <expr> l g:smartJump_half_lastHL <= 0 ? "l" : "5l<cmd>let g:smartJump_half_lastHL-=1<CR>"

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


cmap w!! w !sudo tee % > /dev/null

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
    " visual mode paste should select the pasted content
    " first, fix cursor position after paste (default is - to the end if pasting no linebreak, to the begining of the next line if pasting linebreaks)

    nnoremap <nowait> P "0P
    " vnoremap <nowait> p "0p
    vnoremap <nowait> P "0P
    " nnoremap gp "0gp
    nnoremap gP "0gP
    " pls reserve mp for this
    " vnoremap <nowait> gp  mp"0pv`po
    vnoremap <nowait> gP  mp"0Pv`po

    " voremap d ""d
    vnoremap D "0d
    " nnoremap d ""d
    nnoremap D "0dd
    " nnoremap dd "0dd

" endif
" 6/28/2024, dunno why but the SystemCall check suddenly passed without X11, disabling it

" custom host yank support
let s:clipboard_export = '/mnt/c/clipboard.txt'  " change this path according to your mount point
if filereadable(s:clipboard_export)
  augroup WSLYank
    autocmd!
    " WSL
    " autocmd TextYankPost * if v:event.operator ==# 'y' | call system('echo ' . shellescape(@0) . ' > ' . s:clipboard_export) | endif
    " autocmd TextYankPost * if v:event.operator =~# 'y' | call system('echo ' . shellescape(substitute(@0, '\n$', '', '')) . ' > ' . s:clipboard_export) | endif
    " to deal with '\0' literal, using echo will just interpret it as NULL character
    autocmd TextYankPost * if v:event.operator =~# '\(d\|y\)' | call writefile(split(@0, '\(\n\|\n\r\)', 1), s:clipboard_export, 'b') | endif
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
set <A-o>=o
set <A-O>=*O
inoremap <A-o> <C-o>o<C-o>==
inoremap <A-O> <C-o>O<C-o>==

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
inoremap <expr> <nowait> <Up> col(".") == 1 ? "<Esc>ki" : "<Esc>ka"
inoremap <expr> <nowait> <Down> col(".") == 1 ? "<Esc>ji" : "<Esc>ja"
inoremap <expr> <nowait> <Left> col(".") == 1 ? "<Esc>k$a" : "<Esc>i"
inoremap <expr> <nowait> <Right> col(".") == col("$") ? "<Esc>j0i" : (col(".") == 1 ? "<Esc>li" : "<Esc>la")

" same in normal mode
nnoremap <nowait> <Up> k
nnoremap <nowait> <Down> j
nnoremap <expr> <nowait> <Left> col(".") == 1 ? "k$" : "h"
nnoremap <expr> <nowait> <Right> col(".") == col("$") - 1 ? "j0" : col(".") == col("$") ? "j0" : "l"

" inoremap <expr> <C-L> IsCursorAtEnd() ? "<Cmd>echo 'true'<CR> " : "<Cmd>echo 'false'<CR>"
" insert mode delete until word end
inoremap <expr> <C-e> IsCursorAtEnd() ? "<Del>" : IsCursorAtStart() ? "<Esc>ce" : "<Esc>lce"
" insert mode delete until word begining (excludes current cursor) redundant
" inoremap <expr> <C-w> IsCursorAtStart() ? "<BS>" : IsCursorAtEnd() ? "<Esc>cb<Del>" : "<Esc>lcb"
" insert mode delete current word
" inoremap <expr> <C-c> IsCursorAtLastWord() ? (col('.') == col('$') - 1 ? "<Esc>:set virtualedit=onemore<CR>llbdw:set virtualedit=<CR>xi" : "<Esc>llbdwxi") : "<Esc>llbdwi"
imap <expr> <C-c> IsCursorAtStart() ? "<Esc>viwc" : IsCursorAtEnd() ? "<Esc>viwc" : "<Esc>lviwc"
imap <expr> <C-x> IsCursorAtStart() ? "<Esc>viWc" : IsCursorAtEnd() ? "<Esc>viWc" : "<Esc>lviWc"
" normal mode change current word
" nnoremap <expr> <C-c> IsCursorAtLastWord() ? (col('.') == col('$') - 1 ? ":set virtualedit=onemore<CR>lbdw:set virtualedit=<CR>xi" : "lbdwxi") : "lbdwi"
nmap <C-c> viwc
nmap <C-x> viWc

" increment/decrement alternatives
nnoremap gi <C-a>
nnoremap gx <C-x>

" normal mode delete current word
" nnoremap <expr> <C-D> IsCursorAtLastWord() ? (col('.') == col('$') - 1 ? ":set virtualedit=onemore<CR>lbdw:set virtualedit=<CR>x" : "lbdwx") : "lbdw"
nmap <C-D> viWd

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
command R source ~/.vimrc