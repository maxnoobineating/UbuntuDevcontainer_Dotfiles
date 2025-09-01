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

