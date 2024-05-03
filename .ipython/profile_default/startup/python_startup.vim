" Load the default settings
source ~/.vimrc

" Your custom settings here
" Map 'q' to quit Vim with a non-zero exit code
nnoremap q :cq<CR>

" Map 'Enter' to quit Vim with a zero exit code
nnoremap <CR> :wq<CR>

" automatically moving cursor to the bottom
autocmd BufReadPost * normal G


" disable simplyfold
let g:SimpylFold_docstring_preview = 0
let g:SimpylFold_fold_docstring = 0
let b:SimpylFold_fold_docstring = 0
let g:SimpylFold_fold_import = 0
let b:SimpylFold_fold_import = 0
let g:SimpylFold_fold_blank = 0
let b:SimpylFold_fold_blank = 0
