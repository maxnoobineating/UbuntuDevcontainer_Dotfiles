" =============================================================================================
" Plugins Installation

call plug#begin('~/.vim/plugged')
				let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
                " Install vim-plug if not found
                if empty(glob('~/.vim/autoload/plug.vim'))
                  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
                    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
                endif

				Plug 'mhinz/vim-startify'

                Plug 'dense-analysis/ale'

				Plug 'neoclide/coc.nvim', { 'branch': 'release' }
				Plug 'easymotion/vim-easymotion'

				Plug 'jiangmiao/auto-pairs'

                " requires API keys, or it'll neg you
                Plug 'wakatime/vim-wakatime'

                Plug 'vim-scripts/TaskList.vim'

                Plug 'preservim/nerdtree'

                Plug 'tmhedberg/simpylfold'

                Plug 'majutsushi/tagbar'

                " replaced by tagbar
                " Plug 'xolox/vim-easytags'

                Plug 'xolox/vim-misc'

                " gcc comments
                Plug 'tpope/vim-commentary'

                " quotation surround
                Plug 'tpope/vim-surround'

                " syncing vim unamed register with Tmux buffer
                Plug 'roxma/vim-tmux-clipboard'

                " status bar
                Plug 'vim-airline/vim-airline'
                Plug 'vim-airline/vim-airline-themes'

                " for dealing with vim swapfile warning shenanigans
                " Plug 'gioele/vim-autoswap'

                " for solarized theme as plugin
                " Plug 'altercation/vim-colors-solarized'

                " gruvbox theme as plugin
                " Plug 'morhetz/gruvbox'

                " ack cross file code search
                " Plug 'mileszs/ack.vim'

                " indent indication
                Plug 'yggdroot/indentline'

                " better python syntax highlighting
                Plug 'vim-python/python-syntax'

                " color representation of color code
                Plug 'ap/vim-css-color'

                " color table viewer, :XtermColorTable
                Plug 'guns/xterm-color-table.vim'

                " Fastfold
                Plug 'Konfekt/FastFold'

                " vim-slime
                Plug 'jpalardy/vim-slime'

                " vim-fzf
                Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
                Plug 'junegunn/fzf.vim'


                " Run PlugInstall if there are missing plugins
                " https://github.com/junegunn/vim-plug/wiki/tips#automatic-installation
                autocmd VimEnter * if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
                \| PlugInstall --sync | source $MYVIMRC
                \| endif

call plug#end()


" ############################# "
" Plugin mapping & configuration:


" fzf.vim
" Initialize configuration dictionary
let g:fzf_vim = {}
let g:fzf_action = {
  \ 'return': 'drop',
  \ 'ctrl-t': 'tab drop',
  \ 'ctrl-x': 'split',
  \ 'ctrl-v': 'vsplit' }
nnoremap <leader>ff :Files<CR>
nnoremap <leader>fb :Buffers<CR>
function AgPatternFinder()
    let l:pattern = input('Enter pattern: ')
    execute 'Ag ' . l:pattern
endfunction
nnoremap <leader>fa :call AgPatternFinder()<CR>
nnoremap <leader>ft :Tags<CR>


" vim slime
let g:slime_target = "tmux"
let g:slime_no_mappings = 1
let g:slime_python_ipython = 1
xmap <leader>s <Plug>SlimeRegionSend
nmap <leader>s <Plug>SlimeMotionSend
nmap <leader>ss <Plug>SlimeLineSend


" comments out (not working)
" nnoremap <leader>c <Plug>CommentaryLine
" vnoremap <leader>c <Plug>Commentary

" vim-python
let g:python_highlight_all = 1

" ALE linter setting
" let g:ale_disable_lsp = 1
" 1 for enabling all linters
let g:ale_linters_explicit = 0
let g:ale_linters = {'javascript': [], 'python': ['flake8'], 'rust': [], 'go': [], 'bash': ['shellcheck'], 'sh': ['shellcheck'], 'tex': ['chktex']}
let g:ale_fixers = {'bash': ['shfmt'], 'sh': ['shfmt'], 'python': ['autoflake']}
let g:ale_sign_error = '>>'
let g:ale_sign_warning = '--'
let g:ale_lint_on_text_changed = 'always'


" indentline config
" let g:indentLine_setColors = 0
" Vim
let g:indentLine_color_term = 249
" GVim
" let g:indentLine_color_gui = '#B2B2B2'
let g:indentLine_char = '┊'
" none X terminal
let g:indentLine_color_tty_light = 0 " (default: 4)
let g:indentLine_color_dark = 5 " (default: 2)
                        " asdada

" vim-autoswap config for tmux
let g:autoswap_detect_tmux=1

" plugin theme setting
" autocmd vimenter * ++nested colorscheme gruvbox
" Setting color scheme config before calling colorscheme
let &t_ZH="\e[3m"
let &t_ZR="\e[23m"
" highlight Comment cterm=italic gui=italic
if &term =~ '256color'
  set t_Co=256
endif
set background=dark
let g:solarized_italic=1
let g:solarzied_italic_comments=1
" let g:solarized_contrast="high"
" let g:solarized_termcolors=256
" let g:solarized_termtrans=1
colorscheme solarized
let s:terminal_italic=1

" Vim-airline-themes config
let g:airline_theme='alduin'
" let g:airline_solarized_bg='light'
" Enable tabline
" let g:airline#extensions#tabline#enabled = 1
" let g:airline_powerline_fonts = 1

" airline + tagbar integration
let g:airline#extensions#tagbar#enabled = 1
let g:airline#extensions#tagbar#flags = 'f'

" =======================================================================================================
" tagbar
let g:tagbar_sort = 0
nmap <F8> :TagbarToggle fjc<CR>
" auto tags generation on save
augroup CTagGeneration
    autocmd!
    au BufWritePost * silent! call system('ctags ' . expand('%:p') . '2>&1 >/dev/null &')
    " au BufWinEnter *  expend('%:p')
augroup END

" =======================================================================================================
" NerdTree
nnoremap <leader>n :NERDTreeFocus<CR>

" =======================================================================================================
" Simpylfold, unfold all after fold creation (every new session)
" adding SourcePost event because certain .vim file will ignore foldopen when sourcing ~/.vimrc
autocmd BufWinEnter,SourcePost * silent! :%foldopen!
" set initial maximum nested folding level (only fold if nested over several level), just in case
set foldlevelstart=3

" =======================================================================================================
" Coc.nvim
" config
" for apt installed vim version < v.8.2, disable coc warning
let g:coc_disable_startup_warning = 1
" set selection highlight
let g:coc_global_extensions = [
\ 'coc-pyright',
\ 'coc-json'
\ ]
let g:coc_start_at_startup = 1
set timeout timeoutlen=600 ttimeoutlen=100
" preventing error signs shifting sidebar (can still be disabled by f2)
set signcolumn=yes
autocmd CursorHold * silent call CocActionAsync('highlight')
" mappings
" navigate coc linter message
nmap <silent> <C-j> <Plug>(coc-diagnostic-next-error)
nmap <silent> <C-k> <Plug>(coc-diagnostic-prev-error)
" " opening :CocList diagnostic
" function! s:Err()
"     CocList diagnostics
" endfunction
" com! Err call s:Err()      " Enable :ShowMaps to call the function
" nnoremap <expr> <Leader>e :CocE<CR>
" nnoremap <leader>e <Plug>(coc-diagnostic-info)
nnoremap <leader>e :call CocAction('diagnosticToggle')<CR>

augroup Cocgroup
  autocmd!
  " Setup formatexpr specified filetype(s)
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end
" GoTo code navigation
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
" auto rename
nmap <leader>rn <Plug>(coc-rename)
" auto formatting
nnoremap <leader>af <plug>(coc-format-selected)
vnoremap <leader>af <plug>(coc-format-selected)

" Use K to show documentation in preview window
nnoremap <silent> <leader>d :call ShowDocumentation()<CR>

function! ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doloher')
  else
    call feedkeys('K', 'in')
  endif
endfunction
" Tab Completion binding
" https://github.com/neoclide/coc.nvim/wiki/Completion-with-sources#use-tab-or-custom-key-for-trigger-completion
" Enter confirm with other wise formatted <CR>
" inoremap <silent><expr> <cr> coc#pum#visible() && coc#pum#info()['index'] != -1 ? coc#pum#confirm() : "\<C-g>u\<CR>"
inoremap <silent><expr> <cr> coc#pum#visible() && coc#pum#info()['index'] != -1 ? coc#_select_confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"
" tab S-tab navigate
" inoremap <expr> <Tab> coc#pum#visible() ? coc#pum#next(1) : "\<Tab>"
" inoremap <expr> <S-Tab> coc#pum#visible() ? coc#pum#prev(1) : "\<S-Tab>"
" tab triggering completion
" use <tab> to trigger completion and navigate to the next complete item
function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction
function! ScrollAndNext()
  call coc#pum#next(1)
  call coc#pum#scroll(1)
endfunction
" inoremap <silent><expr> <Tab>
"     \ coc#pum#visible() ?
"         \ coc#pum#next(1) :
"         \ (CheckBackspace() ?
"             \ "\<Tab>" :
"             \ coc#refresh())
inoremap <silent><expr> <Plug>CocNextCompletionCustom
    \ coc#pum#visible() ?
        \ coc#pum#next(1) :
        \ (CheckBackspace() ?
            \ "\<Tab>" :
            \ coc#refresh())
imap <Tab> <Plug>CocNextCompletionCustom

function! ScrollAndPrev()
  call coc#pum#prev(1)
  call coc#pum#scroll(0)
endfunction
inoremap <silent><expr> <S-TAB> 
    \ coc#pum#visible() ?
        \ coc#pum#prev(1) :
        \ "\<C-h>"

" Vim Surrounds
" let b:surround_{char2nr('.')} = "<.>\r</.>"
" let b:surround_{char2nr(',')} = "<,>\r</,>"
" let b:surround_{char2nr('-')} = "<->\r</->"
" let b:surround_{char2nr('_')} = "<_>\r</_>"
" let b:surround_{char2nr('/')} = "</>\r</>"
" let b:surround_{char2nr('\')} = "</>\r</>"

" Simpylfold
" don't fold docstring because some config file will have alot of them
let g:SimpylFold_fold_docstring = 0

" Plugin mappings END
" =======================================================================================================