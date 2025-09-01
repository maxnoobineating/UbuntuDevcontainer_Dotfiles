" Space based mapping
" implicit category: display things

nnoremap <space><space> i<space><Esc>la<space><Esc>h
vnoremap <space><space> <esc>`<i<space><Esc>`>la<space><Esc>`<lv`>l
nnoremap <space>d f<space>xF<space>x
vnoremap <space>d <esc>`>f<space>x`<F<space>x`<hv`>h


" coc tagbar-alternatives? 
nnoremap <silent><nowait> <space>o  :call ToggleOutline()<CR>
