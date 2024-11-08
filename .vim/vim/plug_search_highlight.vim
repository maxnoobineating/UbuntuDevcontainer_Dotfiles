" search for selected text in visual mode
nnoremap <silent> * :let @/= '\<' . expand('<cword>') . '\>' <bar> set hls <cr>
nnoremap <silent> g* :let @/=expand('<cword>') <bar> set hls <cr>
" vnoremap * y:let @/ = "\\M" . substitute(substitute(@" , '\n', '\\n', 'g'), '/', '\/', 'g') . "\\m"<CR>:set hlsearch<CR>
vnoremap * y:let @/ = "\\M" . substitute(escape(@", '\/$'), '\n', '\\n', 'g') . "\\m"<CR>:set hlsearch<CR>
vmap <Plug>(VerityHighlight_Plug_HighlightSelect) *
" vnoremap * y:let @/ =  @"<CR>:set hlsearch<CR>**


function! VerityHighlight_restrictPattern(startpos, endpos, pattern)
  let [l:startLine, l:startCol] = a:startpos
  let [l:endLine, l:endCol] = a:endpos
  return '\(\%>' . l:startLine . 'l\|\(\%>' . (l:startCol-1) . 'c\&\%' . (l:startLine) . 'l\)\)' . a:pattern . '\(\%<' . l:endLine . 'l\|\(\%<' . (l:endCol+2) . 'c\&\%' . (l:endLine) . 'l\)\)'
endfunction

function! VerityHighlight_SolidifiedPattern(pattern)
  let [_, l:startLine, l:startCol, _] = getcharpos("'<")
  let [_, l:endLine, l:endCol, _] = getcharpos("'>")
  let l:pattern = substitute(a:pattern, '\\%V', '', 'g')
  let l:ending_line = getline(l:endLine)
  if l:endCol >= len(l:ending_line)
    " region restriction after \n is counted as next line, although visual selection is counting \n at the same line
    let l:pattern = VerityHighlight_restrictPattern([l:startLine, l:startCol], [l:endLine+1, 0], l:pattern)
  else
  " let @/ = '\(\%>' . l:startLine . 'l\|\(\%>' . (l:startCol-1) . 'c\&\%' . (l:startLine) . 'l\)\)' . @/ . '\(\%<' . l:endLine . 'l\|\(\%<' . (l:endCol+2) . 'c\&\%' . (l:endLine) . 'l\)\)'
    let l:pattern = VerityHighlight_restrictPattern([l:startLine, l:startCol], [l:endLine, l:endCol], l:pattern)
  endif
  return l:pattern
endfunction

function! VerityHighlight_SolidifyHighlight()
  " let [_, l:startLine, l:startCol, _] = getcharpos("'<")
  " let [_, l:endLine, l:endCol, _] = getcharpos("'>")
  " let @/ = substitute(@/, '\\%V', '', 'g')
  " " let @/ = '\(\%>' . l:startLine . 'l\|\(\%>' . (l:startCol-1) . 'c\&\%' . (l:startLine) . 'l\)\)' . @/ . '\(\%<' . l:endLine . 'l\|\(\%<' . (l:endCol+2) . 'c\&\%' . (l:endLine) . 'l\)\)'
  " let @/ = VerityHighlight_restrictPattern([l:startLine, l:startCol], [l:endLine, l:endCol], @/)
  let @/ = VerityHighlight_SolidifiedPattern(@/)
endfunction

nnoremap <Leader>hh  :call VerityHighlight_SolidifyHighlight()<CR>
nmap <Plug>(VerityHighlight_Plug_SolidifyHighlight) <leader>hh
vnoremap <Leader>hh  :<C-u>call VerityHighlight_SolidifyHighlight()<CR>
" temporarily cancel all highlight from search, it'll come back on next search
nnoremap <leader>v :set hlsearch!<CR>

function! VerityHighlight_listOfFieldPosInsidePairs(start_pair, separator, end_pair)
  " return inside component separated by separator in the closest (no further than 2 lines forward) pair
  let [_, l:curLine, l:curCol, _] = getpos('.')
" on cursor fix:
" echo searchpairpos('\zsstart', 'mid', 'end\zs', 'rcb') back
" echo searchpairpos('\zsstart', 'mid', 'end\zs', 'r') forward
  " position search cursor to the nearest pair
  let l:start_pair = a:start_pair
  let l:end_pair = a:end_pair
  let [l:searchStart_line, l:searchStart_col] = searchpairpos('\zs' . l:start_pair, a:separator, l:end_pair . '\zs', 'rcb')
  call input('start: [' . l:searchStart_line . ', ' . l:searchStart_col . ']')
  while [l:searchStart_line, l:searchStart_col] == [0, 0]
    if !(search(l:start_pair)) || (getpos('.')[1] >= (l:curLine + 2))
      call cursor(l:curLine, l:curCol)
      return []
    endif
    let [l:searchStart_line, l:searchStart_col] = searchpairpos('\zs' . l:start_pair, a:separator, l:end_pair . '\zs', 'rcb')
  endwhile
  let l:result_list = []
  let [l:searchEnd_line, l:searchEnd_col] = searchpairpos('\zs' . l:start_pair, a:separator, l:end_pair, '')
  while [l:searchEnd_line, l:searchEnd_col] != [0, 0]
    call input('start: [' . l:searchStart_line . ', ' . l:searchStart_col . '] end: [' . l:searchEnd_line . ', ' . l:searchEnd_col . ']')
    let l:result_list += [[[l:searchStart_line, l:searchStart_col], [l:searchEnd_line, l:searchEnd_col]]]
    let [l:searchStart_line, l:searchStart_col] = [l:searchEnd_line, l:searchEnd_col]
    let [l:searchEnd_line, l:searchEnd_col] = searchpairpos('\zs' . l:start_pair, a:separator, l:end_pair, '')
  endwhile
  call cursor(l:curLine, l:curCol)
  return l:result_list
endfunction

function! VerityHighlight_appendPattern(main, append)
  return '\(' . a:main . '\)\|\(' . a:append . '\)'
endfunction
function! VerityHighlight_concatenatePattern(pattern_list)
  if len(a:pattern_list) < 1
    return ''
  endif
  let l:result = '\(' . a:pattern_list[0] . '\)'
  for l:pattern in a:pattern_list[1:]
    let l:result = l:result . '\|\(' . l:pattern . '\)'
  endfor
  return l:result
endfunction


let g:VerityHighlight_HighlightAdd_storedHighlight = []
function! VerityHighlight_HighlightShow()
  let @/ = VerityHighlight_concatenatePattern(g:VerityHighlight_HighlightAdd_storedHighlight)
endfunction

function! VerityHighlight_HighlightAdd()
  " let g:VerityHighlight_HighlightAdd_timerId = timer_start(500, "VerityHighlight_HighlightAdd_callBack",{"repeat": -1})
  if (strlen(@/) > 1024) && (confirm('Adding potentially nested large pattern, are you sure?', '&Yes\n&No', 1) == 2)
    return 0
  endif
  let g:VerityHighlight_HighlightAdd_storedHighlight = g:VerityHighlight_HighlightAdd_storedHighlight + [@/]
  call VerityHighlight_HighlightShow()
endfunction

function! VerityHighlight_HighlightPop()
  if len(g:VerityHighlight_HighlightAdd_storedHighlight) >= 0
    echo g:VerityHighlight_HighlightAdd_storedHighlight[-1]
    let l:poped = remove(g:VerityHighlight_HighlightAdd_storedHighlight, len(g:VerityHighlight_HighlightAdd_storedHighlight)-1)
    call VerityHighlight_HighlightShow()
    return l:poped
  else
    echo "VerityHighlight_HighlightAdd_storedHighlight already clean"
    call VerityHighlight_HighlightShow()
    return ''
  endif
endfunction

function! VerityHighlight_HighlightClear()
  let g:VerityHighlight_HighlightAdd_storedHighlight = []
  call VerityHighlight_HighlightShow()
  echo "VerityHighlight_HighlightAdd_storedHighlight cleared"
endfunction

nnoremap <leader>h+ :call VerityHighlight_HighlightAdd()<CR>
nmap <Plug>(VerityHighlight_Plug_HighlightAdd) <leader>h+
vmap <leader>h+ <Plug>(VerityHighlight_Plug_HighlightSelect)<Plug>(VerityHighlight_Plug_HighlightAdd)
nnoremap <leader>h- :call VerityHighlight_HighlightPop()<CR>
nnoremap <leader>hd :call VerityHighlight_HighlightClear()<CR>


function! VerityHighlight_inRegion(region_list)
endfunction

function! VerityHighlight_highlightInPair(start_pair, separator, end_pair)
endfunction

" TODO I need to implement an entirely new highlight groups that runs on perl regex...

" TODO plement proper ParameterField function
" change in , separated
" nnoremap ci, v/\([^,]*?\K[)\]}]|)
" nnoremap ci, vi):<C-u>call SepHLSearch()<CR><C-o>
nmap ci, ,h)<C-o><C-n>c<C-o>:noh<CR>
" nnoremap ci,
" nnoremap ci;
" nnoremap ca,
" nnoremap ca;

" vnoremap i,
" vnoremap i;
" vnoremap a,
" vnoremap a;
" nmap di, ,h)


" select around symbols
vnoremap i, t,ot,o
vnoremap a, f,oF,o
vnoremap i. t.oT.o
vnoremap a. f.oF.o
vnoremap i_ t_oT_o
vnoremap a_ f_oF_o
vnoremap i- t-oT-o
vnoremap a- f-oF-o
vnoremap i/ t/oT/o
vnoremap a/ f/oF/o
vnoremap i\ t\oT\o
vnoremap a\ f\oF\o



" select field separated by ,/;(){}[]<>
function! SepHLSearch()
    " TODO try include (?!\s+(?:,|;))[^,;] and [^,;](?<!(?:,|;)\s+) into the pattern (but in god forsaken vim regex) for excluding ,/; bordering whitespace
    let @/ = '\%V[^,;]\+'
    call VerityHighlight_SolidifyHighlight()
endfunction
" vnoremap <leader>ps <Esc>/\%V[^,(){}\[\]><;]\+\%V<CR>
" vnoremap <leader>ps :s/[^,(){}\[\]><;]\+/\1/<CR>v
vnoremap <leader>hv :<C-u>call SepHLSearch()<CR>:set hlsearch<CR>
nnoremap <leader>h) vi):<C-u>call SepHLSearch()<CR>:set hlsearch<CR>
nnoremap <leader>h( vi(:<C-u>call SepHLSearch()<CR>:set hlsearch<CR>
nnoremap <leader>h] vi]:<C-u>call SepHLSearch()<CR>:set hlsearch<CR>
nnoremap <leader>h[ vi[:<C-u>call SepHLSearch()<CR>:set hlsearch<CR>
nnoremap <leader>h} vi}:<C-u>call SepHLSearch()<CR>:set hlsearch<CR>
nnoremap <leader>h{ vi{:<C-u>call SepHLSearch()<CR>:set hlsearch<CR>