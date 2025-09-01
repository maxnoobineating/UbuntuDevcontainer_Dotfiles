
" close window
nnoremap <C-w>d <cmd>q<CR>

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

" nnoremap <C-w>H :wincmd h<CR>:call ResizeVertical(75)<CR>
" nnoremap <C-w><C-j> :wincmd j<CR>:call ResizeHorizontal(75)<CR>
" nnoremap <C-w><C-k> :wincmd k<CR>:call ResizeHorizontal(75)<CR>
" nnoremap <C-w><C-l> :wincmd l<CR>:call ResizeVertical(75)<CR>

function! ChooseWindowPopup() abort
  " Gather IDs of all windows in the current tab.
  let winids = []
  for i in range(1, winnr('$'))
    call add(winids, win_getid(i))
  endfor

  " Create number labels as strings (e.g. "1", "2", "3", …)
  let labels = map(range(1, len(winids)), 'string(v:val)')
  let popups = {}

  " Create a popup for each window.
  for idx in range(0, len(winids)-1)
    let winid = winids[idx]
    let label = labels[idx]

    " Get window position and dimensions.
    let pos = win_screenpos(winid)
    let win_row = pos[0]
    let win_col = pos[1]
    let w = winwidth(winid)
    let h = winheight(winid)
    " Calculate center position in screen (1-indexed)
    let center_row = win_row + float2nr(h/2) - 1
    let center_col = win_col + float2nr(w/2) - 1

    " Configure popup options.
    let opts = {
          \ 'line': center_row,
          \ 'col': center_col,
          \ 'minwidth': 1,
          \ 'minheight': 1,
          \ 'padding': [0, 0, 0, 0],
          \ 'border': [],
          \ 'pos': 'botleft',
          \ 'time': 0,         " persist until manually closed
          \ 'wrap': 0,
          \ }

    " Create the popup with the label.
    let pid = popup_create(label, opts)
    let popups[label] = pid
  endfor

  " Wait for the user to press a key.
  let key = nr2char(getchar())

  " Close all popups.
  for pid in values(popups)
    call popup_close(pid)
  endfor

  " Expect a digit key; convert it to an index (0-based).
  if key =~ '^\d$'
    let index = str2nr(key) - 1
  else
    echo "Invalid selection!"
    return -1
  endif

  if index < 0 || index >= len(winids)
    echo "No window assigned to that number."
    return -1
  endif

  " Return the selected window's ID.
  return winids[index]
endfunction

function! SwapWindows(win1, win2) abort
  " Save the buffer numbers and views for each window.
  let buf1 = winbufnr(a:win1)
  let buf2 = winbufnr(a:win2)
  let view1 = win_execute(a:win1, 'winsaveview()', v:false)
  let view2 = win_execute(a:win2, 'winsaveview()', v:false)

  " Go to first window and load the second window's buffer.
  call win_gotoid(a:win1)
  execute "buffer " . buf2
  call winrestview(view2)

  " Go to second window and load the first window's buffer.
  call win_gotoid(a:win2)
  execute "buffer " . buf1
  call winrestview(view1)
endfunction

