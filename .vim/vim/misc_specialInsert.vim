" insert things with <A-i> in insert mode, <leader>i in normal/visual mode
set <A-i>=i
let s:specialInsert_completefunc_invokeKeys = "\<C-x>\<C-u>"

" just use <C-r> with CMDFuncRedir if you want command output
" " insert command output
" inoremap <silent> <A-i>: <cmd>redir @i<CR><C-o>:

" insert completion

" Tab Completion binding
" https://github.com/neoclide/coc.nvim/wiki/Completion-with-sources#use-tab-or-custom-key-for-trigger-completion
" Enter confirm with other wise formatted <CR>
inoremap <silent><expr> <CR> coc#pum#visible() && coc#pum#info()['index'] != -1 ? coc#pum#confirm() : (
  \ pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>")
" inoremap <nowait><silent><expr> <cr> coc#pum#visible() && coc#pum#info()['index'] != -1 ? coc#_select_confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"
" tab S-tab navigate
" tab triggering completion
" use <tab> to trigger completion and navigate to the next complete item
function! CheckBackspace() abort
  " return number of spaces behind cursor
  let colnum = col('.') - 1
  if colnum == 0
    return 0
  else
    return getline('.')[:colnum-1]->matchstr(' \+$')->strlen()
  endif
endfunction
function! CopyPrevTab()
  if line('.') <= 1 || indent(line('.') - 1) <= shiftwidth()
    return repeat("\<space>", shiftwidth())
  else
    return repeat("\<space>", indent(line('.') - 1))
  endif
endfunction
" inoremap <silent><expr> <Tab> TaborCompletion()
inoremap <silent><expr> <Tab> coc#pum#visible() ? coc#pum#next(1) : (
      \ pumvisible() ? "\<C-n>" : (
        \ col('.') == 1 ? CopyPrevTab() : (
          \ CheckBackspace() > 0 ? "\<Tab>" : coc#refresh())))
inoremap <silent><expr> <S-TAB> coc#pum#visible() ? coc#pum#prev(1) : (
  \ pumvisible() ? "\<C-p>" : "\<C-d>")

" inoremap <silent><expr> <BS> (CheckBackspace() >= shiftwidth()) ? "\<BS>"->repeat(shiftwidth()) : "\<BS>"

inoremap <expr> <A-h> pumvisible() ? "<C-e>" : "<Esc>h"
inoremap <expr> <A-j> pumvisible() ? "<C-e>" : "<Esc>j"
inoremap <expr> <A-k> pumvisible() ? "<C-e>" : "<Esc>k"
inoremap <expr> <A-l> pumvisible() ? "<C-e>" : "<Esc>l"

" all things afterwards are non-repeat
let s:specialInsert_popupWordMaxLen = 7
function SpecialInsert_abbrEmojiComplete(startcol, matches)
  if empty(a:matches)
    return emoji#complete(a:startcol, a:matches)
  endif
  let ret_completeList = emoji#complete(a:startcol, a:matches)
  for item in l:ret_completeList
    let item.abbr = (item.word)->strlen() > s:specialInsert_popupWordMaxLen ? (item.word)[:(s:specialInsert_popupWordMaxLen)] : item.word
  endfor
  let ret_completeList = [{'word': ':', 'kind': ''}] + ret_completeList
  return {'words': ret_completeList, 'refresh': 'always'}
endfunction

" autocmd! CompleteDone <buffer> call timer_start(50, {_ -> CMDFunc('.s/:\([^:]\+\):/\=emoji#for(submatch(1), submatch(0))/ge')})
function SpecialInsert_EmojiReplace()
  " echom "v:completed_item=" v:completed_item
  if v:completed_item->empty()
    return
  endif
  let emoji_pattern = ':\([^:]\+\)'
  let old_colnum = col('.')
  let [lnum, colnum] = searchpos(emoji_pattern, 'nbc')
  if lnum == 0
    return
  endif
  " echom '.s/\%>' . (colnum - 1) . 'c' . emoji_pattern . ':\%<' . (old_colnum + 1) . 'c/\=emoji#for(submatch(1),submatch(0))/ge'
  execute '.s/\%>' . (colnum - 1) . 'c' . emoji_pattern . ':\%<' . (old_colnum + 1) . 'c/\=emoji#for(submatch(1),submatch(0))/ge'
  " call timer_start(50, {_ -> cursor(lnum, old_colnum)})
endfunction
" autocmd! CompleteDone <buffer> normal! v<cmd><CR>"hc<C-o>:let @h=emoji#for(@h[1:-2], @h)<CR><C-r>h

" XXX special insert should start with <A-i>
function SpecialInsert_emoji()
  set completefunc=SpecialInsert_abbrEmojiComplete
  autocmd! CompleteDone * ++once call SpecialInsert_EmojiReplace()
  return ":" . s:specialInsert_completefunc_invokeKeys
endfunction
inoremap <expr> <A-i>e SpecialInsert_emoji()

let s:specialInsert_col = 0
let s:specialInsert_test_completeListNum = 5
function! SpecialInsert_test_complete(findstart, matches)
  if a:findstart == 1
    echom "first invoke, matches=" . string(a:matches)
    let s:specialInsert_col += 1
    return s:specialInsert_col
  elseif a:findstart == 0
    echom "second invoke, matches=" . string(a:matches)
    " let g:specialInsert_testStr = a:matches[:(s:specialInsert_test_completeListNum)+1]
    " return {'words': range(s:specialInsert_test_completeListNum)->map('g:specialInsert_testStr[v:val] . "gozaru!"'), 'refresh': 'always'}
    return {'words': ['words1', 'wos', '33'], 'refresh': 'always'}
  endif
endfunction

function! SpecialInsert_test()
  set completefunc=SpecialInsert_test_complete
  " set completeopt+=noselect
  return s:specialInsert_completefunc_invokeKeys
endfunction
inoremap <expr> <A-i>t SpecialInsert_test()

function! SpecialInsert_test_complete(findstart, matches)
  if a:findstart == 1
    echom "first invoke, matches=" . string(a:matches)
    return 0
  elseif a:findstart == 0
    echom "second invoke, matches=" . string(a:matches)
    return {'words': ['11', '22', '33'], 'refresh': 'always'}
  endif
endfunction

function! SpecialInsert_test()
  set completefunc=SpecialInsert_test_complete
  return "\<C-x>\<C-u>"
endfunction
inoremap <expr> <A-i>t SpecialInsert_test()
inoremap <A-i>d <cmd>call complete(1, ['11', '22', '33'])<CR>

" function! SpecialInsert_completefuncReInvoke()
"   echom "## complete info: " string(complete_info()->filter('v:key != "items"'))
"   echom "## v:event=" v:event
" endfunction
" autocmd TextChangedP * call SpecialInsert_completefuncReInvoke()