" fzf.vim
" search syntax: https://github.com/junegunn/fzf#search-syntax
" Initialize configuration dictionary
let g:fzf_vim = {}

" [Buffers] Jump to the existing window if possible
let g:fzf_vim.buffers_jump = 1
" [Tags] Command to generate tags file
let g:fzf_vim.tags_command = 'ctags -R'


" ##########
" standardized source format
let s:Fzf_sourceFormat_fieldType = {
  \ "itemSorter": 0,
  \ "itemView": 1,
  \ "itemSearchString": 2,
  \ "file": 3,
  \ }
let s:Fzf_sourceFormat_delim = '|'
function! FzfHelper_sourceFormater(sourceDict)
  let sourceList = []
  for key in s:Fzf_sourceFormat_fieldType->keys()
    if a:sourceDict->haskey(key)
      let sourceList += a:sourceDict[key]->escape(s:Fzf_sourceFormat_delim)
    else
      let sourceList += ['']
    endif
  endfor
  return sourceList->join(s:Fzf_sourceFormat_delim)
endf
function! FzfHelper_lineParser(line)
  let lineList = line->split('\\@<!' . s:Fzf_sourceFormat_delim, v:true)
endf
" Fzf change file type (mainly for Enter-c command window)
function! ChooseFiletypeFzf()
  " Gather a list of filetype names from syntax files in the runtime.
  let l:syntax_files = split(globpath($VIMRUNTIME, 'syntax/*.vim'), "\n")
  let l:filetypes = uniq(map(l:syntax_files, 'fnamemodify(v:val, ":t:r")'))

  " Run fzf with a centered half-window layout.
  call fzf#run({
        \ 'source': l:filetypes,
        \ 'sink': {selected -> execute('set filetype=' . selected)},
        \ 'window': { 'width': 0.2, 'height': winheight(0) * 0.8 / &lines, 'xoffset': (winwidth(0) - 9) * 0.5 / winwidth(0), 'yoffset': 0.9}
        \ })
endfunction

"FZF Buffer Delete
" author: https://www.reddit.com/r/neovim/comments/mlqyca/fzf_buffer_delete/
if !exists('g:bufLastUsed_reltime')
  let g:bufLastUsed_reltime = {}
endif
eval g:startify_session_savevars->ListAddUnique('g:bufLastUsed_reltime')
autocmd! BufLeave * let g:bufLastUsed_reltime[expand('<afile>:p')] = reltime()
function! FzfBD_bufLastUsed(ls_buf1, ls_buf2)
  let buf1 = FzfBD_getFzfBufnr(a:ls_buf1)
  let buf2 = FzfBD_getFzfBufnr(a:ls_buf2)
  " let reltime1 = buf1->getbufinfo()[0].variables->get('bufLastUsed_reltime', [0, 0])
  " let reltime2 = buf2->getbufinfo()[0].variables->get('bufLastUsed_reltime', [0, 0])
  let reltime1 = g:bufLastUsed_reltime->get(buf1->getbufinfo()[0].name, [0, 0])
  let reltime2 = g:bufLastUsed_reltime->get(buf2->getbufinfo()[0].name, [0, 0])
  return ReltimeDiff(reltime1, reltime2) <= 0 ? 1 : -1
endfunction
function! FzfBD_listBuffers()
  redir => list
  silent ls
  redir END
  let retList = split(list, "\n")
  let retList = sort(retList, function('FzfBD_bufLastUsed'))
  return retList
endfunction

function! FzfBD_deleteBuffers(lines)
  " echo "FzfBD_deleteBuffers: " . string(a:lines)
  execute 'bdelete!' join(map(a:lines, {_, line -> split(line)[0]}))
endfunction

function! FzfBD_tabDrop_sink(line)
  execute "TabDrop b " . FzfBD_getFzfBufnr(a:line)
endfunction

function! FzfBD_sinkList_expect(lines)
  " echom "## fzf expected: ".string(a:lines)
  " return
  if a:lines[0] == 'enter'
    let sinkCMD = "TabDrop b "
  elseif a:lines[0] == 'ctrl-d'
    let sinkCMD = "bdelete! "
  elseif a:lines[0] == 'ctrl-m'
    call s:FzfPrintLines(a:lines)
    return
  endif
  for line in a:lines[1:]
    execute sinkCMD . FzfBD_getFzfBufnr(line)
  endfor
endfunction

function! FzfBD_getFzfBufnr(fzf_output)
  " echom "FzfBD_getFzfBufnr(" . string(a:fzf_output) . ")"
  let fzf_list = split(a:fzf_output, " ")
  " echom string(split(a:fzf_output, " "))
  return str2nr(fzf_list[0])
endfunction

" let s:fzfBD_listeningServerName = 'fzfBD'
" let s:fzfBD_RCEServer_handle = RCEChannel_RCEServerStart(s:fzfBD_listeningServerName)
" let [s:fzfBD_RCEfzf2relay_pipe, s:fzfBD_RCErelay2fzf_pipe, s:fzfBD_RCEjobid] = s:fzfBD_RCEServer_handle
" let s:fzfBD_RCEshellscript_ctrl_t =
"       \ RCEChannel_executeInVim_shellscript('execute ' . shellescape('tabnew +b\\\\ ') . '. FzfBD_getFzfBufnr("{}")'
"         \ , s:fzfBD_RCEfzf2relay_pipe
"         \, s:fzfBD_RCErelay2fzf_pipe)
"       " omg '\' * 11
"       " \ RCEChannel_executeInVim_shellscript('echom "tabnew +b\\\\\\\\\\\ " . FzfBD_getFzfBufnr("{}")', s:fzfBD_RCEfzf2relay_pipe)
" let s:fzfBD_RCEshellscript_ctrl_d =
"       \ RCEChannel_executeInVim_shellscript('execute "bdelete " . FzfBD_getFzfBufnr("{}")'
"         \ , s:fzfBD_RCEfzf2relay_pipe
"         \, s:fzfBD_RCErelay2fzf_pipe)
" let s:fzfBD_RCEshellscript_enter =
"       \ RCEChannel_executeInVim_shellscript('execute "TabDrop b " . FzfBD_getFzfBufnr("{}")'
"         \ , s:fzfBD_RCEfzf2relay_pipe
"         \, s:fzfBD_RCErelay2fzf_pipe)
"       " \ RCEChannel_executeInVim_shellscript('execute "TabDrop b " . FzfBD_getFzfBufnr("{}")'
"       "   \ , s:fzfBD_RCEfzf2relay_pipe)
" let s:fzfBD_RCEshellscript_testEchom =
"       \ RCEChannel_executeInVim_shellscript('echom "vim received:{}"'
"         \ , s:fzfBD_RCEfzf2relay_pipe
"         \, s:fzfBD_RCErelay2fzf_pipe)

let s:optionBind_BD = "alt-a:select-all,ctrl-/:toggle-preview"
" let s:optionBind_BD .= ',ctrl-t:execute(' . s:fzfBD_RCEshellscript_ctrl_t . ')'
" let s:optionBind_BD .= ',ctrl-d:execute(' . s:fzfBD_RCEshellscript_ctrl_d . ')'
" let s:optionBind_BD .= ',ctrl-s:execute(' . s:fzfBD_RCEshellscript_ctrl_d . ')'
" let s:optionBind_BD .= ',enter:execute(' . s:fzfBD_RCEshellscript_enter . ')'
let s:fzfBufManager_previewScript = "echo {} | cut -d'\"' -f2 | xargs -I _ batcat --color=always -p _"
" let s:fzfBufManager_previewScript = "echo {} | cut -d' ' -f1"
" let s:fzfBufManager_previewScript = "echo {}"
command! BufManager call fzf#run(fzf#wrap({
      \ 'source': FzfBD_listBuffers(),
      \ 'sinklist': function('FzfBD_sinkList_expect'),
      \ 'options': '--multi '
      \ . '--no-sort '
      \ . '--expect=ctrl-d,ctrl-m,enter '
      \ . '--bind='
      \ . fzf#shellescape(s:optionBind_BD)
      \ . ' --preview='
      \ . fzf#shellescape(s:fzfBufManager_previewScript)}))

command! BD call fzf#run(fzf#wrap({
  \ 'source': FzfBD_listBuffers(),
  \ 'sink*': function('FzfBD_deleteBuffers'),
  \ 'options': '--multi --reverse'
\ }))

nnoremap <C-b>D :BD<CR>
" ##########

" An action can be a reference to a function that processes selected lines
function! s:build_quickfix_list(lines)
  let qflist = []
  for line in a:lines
    let [filename, linenr, colnr] = split(l:line, ':')[:2]
    let l:qflist += [{"filename": l:filename , "lnum": l:linenr}]
  endfor
  echom string(l:qflist)
  silent call setqflist(l:qflist)
  " silent TabDrop copen
endfunction
" \ 'ctrl-q': function('s:build_quickfix_list') // unwieldy because ag doesn't supports function call for items
" just use default quickfix
let g:fzf_vim.listproc = { list -> fzf#vim#listproc#quickfix(list) }

function! s:FZFTestEchom(lines)
  echom "##:" . string(a:lines)
  " supposedly keep fzf from closing?
  return 0
endfunction

function! s:FzfAction_tabDropWrapper(lines)
  if len(a:lines) == 1
    let [filename, linenr, colnr] = split(a:lines[0], ':')[:2]
    silent execute "TabDrop tabnew " . filename
    call cursor(l:linenr, l:colnr)
  elseif len(a:lines) > 1
    for line in a:lines
      let [filename, linenr, colnr] = split(l:line, ':')[:2]
      silent execute "TabDrop tabnew " . filename
      call cursor(l:linenr, l:colnr)
    endfor
  endif
endfunction

function! s:FzfPrintLines(lines)
  " echom join(map(a:lines, function('string')), '\n')
  " echom join(a:lines, '\n')
  echom "### Fzf selected lines arguments: ###"
  for line in a:lines
    echom l:line
  endfor
  return 0
endfunction

let g:fzf_vim.preview_window = ['hidden,right,70%,wrap', 'ctrl-/']
  " \ 'ctrl-q': function('fzf#vim#listproc#quickfix'),
let g:fzf_action = {
  \ 'ctrl-q': function('s:build_quickfix_list'),
  \ 'ctrl-d': function('FzfBD_deleteBuffers'),
  \ 'enter': function('s:FzfAction_tabDropWrapper'),
  \ 'ctrl-t': 'tabnew',
  \ 'ctrl-m': function('s:FzfPrintLines'),
  \ 'ctrl-x': 'split',
  \ 'ctrl-v': 'vsplit' }
let g:fzf_history_dir = '~/.local/share/fzf-history'
" quickfix list (technically doesn't belong here) stepping
" in fzf popup, <alt-a> to select all, enter to add all to the quickfix list, then using this to step over them

" fzf popup mappings
nnoremap <leader>ff :Files<CR>
nnoremap <leader>fF :Files!<CR>
" nnoremap <leader>fb :Buffers<CR>
" nnoremap <leader>fB :Buffers!<CR>
nnoremap <leader>fb <cmd>BufManager<CR>
let s:fzf_findAnything_historyFileName = 'fzf_fa'
function! FzfRg_sinkList_expect(lines)
  " echom "## fzf expected: ".string(a:lines)
  " return
  if a:lines[0] == 'enter'
    let sinkCMD = "TabDrop tabnew "
  elseif a:line[0] == 'ctrl-t'
    call FzfAction_tabDropWrapper(a:lines)
    return
  elseif a:lines[0] == 'ctrl-m'
    call s:FzfPrintLines(a:lines)
    return
  endif
  for line in a:lines[1:]
    execute sinkCMD . FzfBD_getFzfBufnr(line)
  endfor
endfunction

command! -bang -nargs=* Rg
  \ call fzf#vim#grep(
  \   "rg --column --line-number --no-heading --color=always --smart-case -- ".shellescape(<q-args>), 1,
  \   fzf#wrap(s:fzf_findAnything_historyFileName, fzf#vim#with_preview({
        \ 'dir': getcwd(),
        \ 'options':
        \ ' --expect='
        \ . fzf#shellescape('ctrl-t,enter')})), <bang>0)
nnoremap <leader>fa :Rg<CR>
nnoremap <leader>fA :Rg!<CR>
nnoremap <leader>ft :Tags<CR>
nnoremap <leader>fT :Tags!<CR>
nnoremap <leader>fl :BLines<CR>
nnoremap <leader>fL :Lines<CR>
" alternative *man* *manpage* *:Man* with fzf search, author: "https://www.reddit.com/r/vim/comments/mg8ov7/fuzzily_searching_man_pages_using_fzfvim/"
" command! -nargs=? Apropos call fzf#run(fzf#wrap({'source': 'man -k -s 1 '.shellescape(<q-args>).' | cut -d " " -f 1', 'sink': 'tab Man', 'options': ['--preview', "MANPAGER=\"sh -c 'col -bx | batcat -l man -p'\" MANWIDTH=".(&columns/2-4).' man {}']}))
let s:fzf_findManpage_historyFileName = "fzf_fm"
command! -nargs=* ManApropos execute "Man " . <q-args>->split()[0] . <q-args>->split()[1]
function! FZFApropos_getDict(args)
  let l:retdict = fzf#wrap(s:fzf_findManpage_historyFileName, {
        \ 'source': 'man -k ' . fzf#shellescape(a:args),
        \ 'sink': 'TabDrop ManApropos',
        \ 'options':
        \ ' --bind='
        \ . fzf#shellescape('ctrl-/:toggle-preview')
        \ . ' --preview='
        \ . fzf#shellescape('echo {} | '
        \ . g:manpage_apropos2manindex
        \ . " | xargs -I _ man _"
        \ . " | col -bx"
        \ . " | batcat --color=always -l man -p")
        \ . ' --preview-window=hidden,wrap,70%'})
  " let l:retdict['_action'] = l:retdict->get('_action', {})
  " let l:retdict['_action']['ctrl-t'] = 'cancel'
  " echon string(l:dict)->substitute(',', "\n", 'g')
  return l:retdict
endfunction
command! -nargs=? Apropos call fzf#run(FZFApropos_getDict(<q-args>))
" command! -nargs=? Apropos call FZFApropos_getDict(<q-args>)
" command! -nargs=? Apropos call fzf#run(fzf#wrap({'source': 'man -k -s 1 '.shellescape(<q-args>).' | cut -d " " -f 1', 'sink': 'tab Man', 'options': ['--preview', "man {}"]}))
nnoremap <leader>fm :Apropos .<CR>

" change directory with fzf, author: "https://github.com/craigmac/vimfiles/blob/17ed01fb597f14ec8b2c0d1dc41e72c17ff69d41/vimrc#L228"
" command! -bang -bar -nargs=? -complete=dir FZFCd
" 	\ call fzf#run(fzf#wrap(
" 	\ {'source': 'find '..( empty("<args>") ? ( <bang>0 ? "~" : "." ) : "<args>" ) ..
" 	\ ' -type d -maxdepth 1', 'sink': 'cd'}))
" not what I wanted

"fzf change directory
function! FzfExplore(...)
  if a:1 =~ "enter"
    return
  elseif a:1 =~ "ctrl-t"
    execute "tabnew"
  elseif a:1 =~ "ctrl-v"
    execute "vnew"
  elseif a:1 =~ "ctrl-s"
    execute "new"
  else
    let inpath = substitute(a:1, "'", '', 'g')
    echo matchend(inpath, '/')
    if inpath == "" || matchend(inpath, '/') == strlen(inpath)
      execute "cd" getcwd() . '/' . inpath
      let cwpath = getcwd() . '/'
      let cmd = 'ls -1p; echo ../'
      let spec = fzf#vim#with_preview({'source': cmd, 'dir': cwpath, 'sink': 'FZFExplore', 'options': ['--prompt', cwpath, '--expect=ctrl-t,ctrl-v,ctrl-s,enter']})
      call fzf#run(fzf#wrap(spec))
    else
      let file = getcwd() . '/' . inpath
      execute "e" file
      set acd
    endif
  endif
endfunction
command! -nargs=* FZFExplore set noacd | call FzfExplore(<q-args>)
nnoremap <leader>fd <cmd>FZFExplore<CR>

let s:fzf_findFileDir_historyFileName = 'fzfFD'
function! FzfActionMulti_fileExplorer(lines)
  " error!
endf
" Function to launch fzf and list files/directories/symlinks in long listing style.
function! FzfListFiles() abort
  " Get current working directory.
  let cwd = getcwd()
  " Build a command that:
  " - Recursively finds all items under the cwd (-mindepth 1)
  " - For each item, prints its full path followed by a delimiter "|" (using echo -n)
  " - Then appends the output of "ls -ld --color=always" for that item.
  " This produces lines like:
  "   ./path/to/item|drwxr-xr-x  3 user group 4096 Jan  1 12:00 ./path/to/item
  let cmd = 'find ' . shellescape(cwd) . ' -mindepth 1 -exec echo -n "{}|" \; -exec ls -ld --color=always {} +'
  
  " fzf options:
  " --ansi           : interpret ANSI escape sequences.
  " --delimiter="|"  : use "|" as the field separator.
  " --nth=2..       : display fields starting from the second one (i.e. skip the full path).
  let opts = '--ansi --delimiter="|" --nth=2..'
  
  " Call fzf-vim using fzf#vim#fzf():
  let fzfwrap = fzf#wrap(s:fzf_findAnything_historyFileName, {
        \ 'source': cmd,
        \ 'options': opts,
        \ 'sink': {line->CMDFunc("echom " . string(line))}
        \ })
  call fzf#run(fzfwrap)
endfunction

function! FzfActionMono_fileExplorer(line)
  " line is supposed to be a full path
  let l:retdict = fzf#wrap(s:fzf_findFileDir_historyFileName, {
        \ 'source': 'man -k ' . fzf#shellescape(a:args),
        \ 'sink': 'TabDrop ManApropos',
        \ 'options':
        \ ' --bind='
        \ . fzf#shellescape('ctrl-/:toggle-preview')
        \ . ' --preview='
        \ . fzf#shellescape('echo {} | '
        \ . g:manpage_apropos2manindex
        \ . " | xargs -I _ man _"
        \ . " | col -bx"
        \ . " | batcat --color=always -l man -p")
        \ . ' --preview-window=hidden,wrap,70%'})
endf

function! FzfHelper_binding(bindings)
  let retStr = ''
  for key in a:bindings->keys()
    let retStr .= " --bind=" . shellescape(key . ':' . a:bindings[key])
  endfor
  return retStr
endf

" open all vim mappings table
nmap <leader>mn <plug>(fzf-maps-n)
nmap <leader>mi <plug>(fzf-maps-i)
nmap <leader>mv <plug>(fzf-maps-x)
omap <leader>mo <plug>(fzf-maps-o)
" <leader>mm implemented seperately