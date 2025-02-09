" =============================================================================================
" Plugins Installation


call plug#begin('~/.vim/plugged')
    let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
    " Install vim-plug if not found
    if empty(glob('~/.vim/autoload/plug.vim'))
      silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
        \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    endif

    " Notational-fzf-vim: fzf noteTaking
    " Plug 'https://github.com/alok/notational-fzf-vim'

    " hyperlinked with vimWiki and vim-zettel
    " Plug 'vimwiki/vimwiki'
    " Plug 'michal-h21/vim-zettel'

    Plug 'mhinz/vim-startify'

    " file icons for bunch of things
    Plug 'ryanoasis/vim-devicons'

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
    " Plug 'roxma/vim-tmux-clipboard'

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

    " git gutter
    Plug 'airblade/vim-gitgutter'

    " Run PlugInstall if there are missing plugins
    " https://github.com/junegunn/vim-plug/wiki/tips#automatic-installation
    autocmd VimEnter * if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
    \| PlugInstall --sync | source $MYVIMRC
    \| endif

    " undo tree
    Plug 'mbbill/undotree'

    " automatic tag generation
    " Plug 'ludovicchabant/vim-gutentags'

    " go development package
    Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }

    " custom text object
    Plug 'kana/vim-textobj-user'

    " html/css utils
    Plug 'mattn/emmet-vim'

    " javascript
    Plug 'pangloss/vim-javascript'

call plug#end()


" ############################# "
" Plugin mapping & configuration:

" emmet vim html/css
let g:user_emmet_install_global = 0
let g:user_emmet_complete_tag = 0
" imap <C-f> should be reserved for filetype specific leader key
let g:user_emmet_leader_key='<C-f>'
" vmap <C-f>u <Plug>(emmet-update-tag)
autocmd FileType html,css EmmetInstall


" textobj

" vim-go
let g:go_diagnostics_level = 0
let g:go_diagnostics_enabled = 0
let g:go_metalinter_enabled = []
let g:go_def_mode='gopls'
let g:go_info_mode='gopls'
let g:go_doc_keywordprg_enabled = 0
let g:go_def_mapping_enabled = 0
let g:go_doc_popup_window = 1
let g:go_highlight_chan_whitespace_error = 1
let g:go_highlight_extra_types = 1
let g:go_highlight_space_tab_error = 1
let g:go_highlight_trailing_whitespace_error = 1
let g:go_highlight_operators = 1
let g:go_highlight_functions = 1
let g:go_highlight_function_parameters = 1
let g:go_highlight_function_calls = 1
let g:go_highlight_types = 1
let g:go_highlight_fields = 1
let g:go_highlight_build_constraints = 1
let g:go_highlight_generate_tags = 1
let g:go_highlight_string_spellcheck = 1
let g:go_highlight_format_strings = 1
let g:go_highlight_variable_declarations = 1
let g:go_highlight_variable_assignments = 1
let g:go_highlight_diagnostic_errors = 1
let g:go_highlight_diagnostic_warnings = 1


" gutentags setup
" autocmd VimEnter  *  if expand('<amatch>')==''|call gutentags#setup_gutentags()|endif

" startify
" disable notimeout in startify, because the session indices selection no longer works (number pending further command indefinitely)
augroup StartifyAug
  " autocmd! FileType startify set timeout
  " " timout option can't be set locally, so resetting is required
  " autocmd! FileType *\(startify\)\@<! set notimeout
  call SetFiletypeTimeout('startify', v:true, 100)
augroup END
" auto-pairs
let g:AutoPairsMapCR = 0

" startify session save
nnoremap <C-w><C-s> :SSave<CR>
let g:startify_session_persistence = 1

" let g:startify_session_before_save = [ 'silent! call CloseBuffersType("help")', 'silent! call CloseBuffersType("man")']
let g:startify_session_before_save = [ 'silent! call CloseSpecialBuffers()', 'silent! call CloseUnusedBuffers()']
let g:startify_session_savevars = [
      \ 'g:startify_session_savevars',
      \ 'g:startify_session_savecmds'
      \ ]
let g:startify_session_savecmds = []

let g:startify_lists = [
      \ { 'type': 'sessions',  'header': ['   Sessions']       },
      \ { 'type': 'files',     'header': ['   MRU']            },
      \ { 'type': 'dir',       'header': ['   MRU '. getcwd()] },
      \ { 'type': 'bookmarks', 'header': ['   Bookmarks']      },
      \ { 'type': 'commands',  'header': ['   Commands']       },
      \ ]

" prevent conflict with NERDTree
let NERDTreeHijackNetrw = 0


" Gundo
nnoremap <F5> :UndotreeToggle<CR>

" =====================================================

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
let g:ale_sign_error = '✗'
let g:ale_sign_warning = '⚠️'
let g:ale_virtualtext_cursor = 0
let g:ale_linters_explicit = 0
let g:ale_linters = {
            \ 'python': ['flake8'],
            \ 'rust': [],
            \ 'go': ['golangci-lint'],
            \ 'bash': ['shellcheck'],
            \ 'sh': ['shellcheck'],
            \ 'tex': ['chktex'],
            \ 'c': ['gcc', 'clang'],
            \ 'cpp': ['g++', 'clang++'],
            \ 'javascript': ['eslint']}
let g:ale_fixers = {'bash': ['shfmt'],
      \ 'sh': ['shfmt'],
      \ 'python': ['autoflake'],
      \ 'c': ['clang-format'],
      \ 'cpp': ['clang-format'],
      \ 'javascript': ['prettier', 'eslint']}
let g:ale_sign_error = '>>'
let g:ale_sign_warning = '--'
let g:ale_lint_on_text_changed = 'always'
" better C/C++ linting
let g:ale_cpp_clangd_executable = 'clangd'


" indentline config
let g:indentLine_autoResetWidth = 1
" let g:indentLine_setColors = 0
" Vim
let g:indentLine_color_term = 249
" GVim
" let g:indentLine_color_gui = '#B2B2B2'
let g:indentLine_char = '┊'
" none X terminal
let g:indentLine_color_tty_light = 0 " (default: 4)
let g:indentLine_color_dark = 5 " (default: 2)

if exists('g:indentLine_fileTypeExclude')
  eval g:indentLine_fileTypeExclude->ListAppendUnique(g:specialFileType_list)
else
  let g:indentLine_fileTypeExclude = g:specialFileType_list
endif

if exists('g:indentLine_bufTypeExclude')
  eval g:indentLine_bufTypeExclude->ListAppendUnique(g:specialBufferType_list)
else
  let g:indentLine_bufTypeExclude = g:specialBufferType_list
endif


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
let g:airline_theme='my_alduin'
" let g:airline_solarized_bg='light'
" Enable tabline
" let g:airline#extensions#tabline#enabled = 1
" let g:airline#extensions#tabline#show_buffers = 1
" let g:airline_powerline_fonts = 1
" let g:airline#extensions#tabline#fnamemod = ':t'

" airline + tagbar integration
let g:airline#extensions#tagbar#enabled = 1
let g:airline#extensions#tagbar#flags = 'f'
" mode display
  let g:airline_mode_map = {
      \ '__'     : '-',
      \ 'c'      : 'C',
      \ 'i'      : 'I',
      \ 'ic'     : 'I',
      \ 'ix'     : 'I',
      \ 'n'      : 'N',
      \ 'multi'  : 'M',
      \ 'ni'     : 'N',
      \ 'no'     : 'N',
      \ 'R'      : 'R',
      \ 'Rv'     : 'R',
      \ 's'      : 'S',
      \ 'S'      : 'S',
      \ 't'      : 'T',
      \ 'v'      : 'V',
      \ 'V'      : 'V',
      \ }

" =======================================================================================================
" tagbar
let g:tagbar_sort = 0
nmap <F8> :TagbarToggle fjc<CR>
" auto tags generation on save
augroup CTagGeneration
    autocmd!
    " au BufWritePost * silent! call system('ctags -R' . expand('%:p') . '2>&1 >/dev/null &')
    " au BufWinEnter *  expend('%:p')
augroup END

" =======================================================================================================
" NerdTree
" nnoremap <leader>n :NERDTreeFocus<CR>
nnoremap <leader>nn :NERDTreeFind<CR>
nnoremap <leader>ng :NERDTreeToggleVCS<CR>
let g:NERDTreeShowHidden=1
let g:NERDTreeMinimalUI=1
let g:NERDTreeDirArrows=1
let g:NERDTreeMapCWD='b'
augroup NerdTree
  " default g:NERDTreeMapQuit seems to dangle if notimeout is set
  " autocmd FileType nerdtree nnoremap <nowait> <buffer> q :q<CR>
  autocmd FileType nerdtree nnoremap <nowait> <buffer> q :q<CR>
  call SetFiletypeTimeout('nerdtree', v:true, 100)
augroup End

" =======================================================================================================
" Simpylfold, unfold all after fold creation (every new session)
" adding SourcePost event because certain .vim file will ignore foldopen when sourcing ~/.vimrc
autocmd! BufWinEnter,SourcePost * if &buftype=='' | try | silent! %foldopen! | catch | EchomWarn expand('<afile>') . "foldopen failed!" | endtry | endif
" autocmd! BufWinEnter,SourcePost * if !IsSpecialBuffer(&filetype) | echom "???" | endif
" set initial maximum nested folding level (only fold if nested over several level), just in case
set foldlevelstart=3
" don't fold docstring because some config file will have alot of them
let g:SimpylFold_fold_docstring = 0

" =======================================================================================================
" Coc.nvim
" config
" for apt installed vim version < v.8.2, disable coc warning
let g:coc_disable_startup_warning = 1
" set selection highlight
let g:coc_global_extensions = [
\ 'coc-pyright',
\ 'coc-json',
\ 'coc-clangd',
\ 'coc-snippets',
\ 'coc-go',
\ 'coc-css',
\ 'coc-html',
\ 'coc-snippets',
\ 'coc-tsserver',
\ 'coc-emoji'
\ ]
let g:coc_start_at_startup = 1
" set timeout timeoutlen=600 ttimeoutlen=100
" preventing error signs shifting sidebar (can still be disabled by f2)
set signcolumn=yes
autocmd CursorHold * silent call CocActionAsync('highlight')
" mappings
" navigate coc linter message
nmap <silent> <leader>en <Plug>(coc-diagnostic-next-error)
nmap <silent> <leader>ep <Plug>(coc-diagnostic-prev-error)
" " opening :CocList diagnostic
" function! s:Err()
"     CocList diagnostics
" endfunction
" com! Err call s:Err()      " Enable :ShowMaps to call the function
" nnoremap <expr> <Leader>e :CocE<CR>
" nnoremap <leader>e <Plug>(coc-diagnostic-info)
nnoremap <leader>ee :call CocAction('diagnosticToggle')<CR>:ALEToggle<CR>

augroup Cocgroup
  autocmd!
  " Setup formatexpr specified filetype(s)
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end
" GoTo code navigation
set tagfunc=CocTagFunc " gt to use coc tag jump
let g:cocJump_previousFile = ''
nmap <silent> gd :let g:cocJump_previousFile=expand('%:p')<CR><Plug>(coc-definition)
nmap <silent> gy :let g:cocJump_previousFile=expand('%:p')<CR><Plug>(coc-type-definition)
nmap <silent> gi :let g:cocJump_previousFile=expand('%:p')<CR><Plug>(coc-implementation)
nmap <silent> gr :let g:cocJump_previousFile=expand('%:p')<CR><Plug>(coc-references)
" even if this isn't coc option, the command are similar
" expand expand '<cfile>' because <cfile> expand into file path, than file path string is expanded with wild card escaped
" nnoremap <silent> gf :let g:cocJump_previousFile=expand('%:p')<CR>:if filereadable(expand(expand('<cfile>'))) \| execute "TabDrop tabnew " . expand('<cfile>') \| endif<CR>
nnoremap <silent> gf <cmd>let g:cocJump_previousFile=expand('%:p')<CR><cmd>execute "silent! TabDrop normal! gf"<CR>
" nnoremap <silent> gF :let g:cocJump_previousFile=expand('%:p')<CR>:if filereadable(expand(expand('<cfile>'))) \| execute "TabDrop tabnew " . expand('<cfile>') \| tabprevious \| endif<CR>
nnoremap <silent> gF
  \
  \<cmd>let g:cocJump_previousFile=expand('%:p')<CR>
  \
  \<cmd>execute "silent! TabDrop normal! gf"<CR>
  \
  \<cmd>call timer_start(TabAction_getTabDropTimerlen(), { timer_id -> CMDFunc("if g:cocJump_previousFile != expand('%:p') \| tabprevious \| endif")})<CR>
 

function! CocJump_DropLastJumpFile()
    if exists('g:cocJump_previousFile') && !empty(g:cocJump_previousFile)
        execute 'drop' g:cocJump_previousFile
    else
        echo "No file saved in jump history"
    endif
endfunction
nmap gb :call CocJump_DropLastJumpFile()<CR>
nmap <silent> gm :let g:cocJump_previousFile=expand('%:p')<CR><Plug>ManPreGetPage

" auto rename
nmap <leader>rn <Plug>(coc-rename)
" auto formatting
nnoremap <leader>af <plug>(coc-format-selected)
vnoremap <leader>af <plug>(coc-format-selected)

" Applying code actions to the selected code block
" Example: `<leader>aap` for current paragraph
" xmap <leader>a  <Plug>(coc-codeaction-selected)
" nmap <leader>a  <Plug>(coc-codeaction-selected)

" " Remap keys for applying code actions at the cursor position
" nmap <leader>ac  <Plug>(coc-codeaction-cursor)
" " Remap keys for apply code actions affect whole buffer
" nmap <leader>as  <Plug>(coc-codeaction-source)
" " Apply the most preferred quickfix action to fix diagnostic on the current line
" nmap <leader>qf  <Plug>(coc-fix-current)

nmap <nowait> <leader>a <Plug>(coc-codeaction-cursor)

" Use K to show documentation in preview window
nnoremap <silent> <leader>d :call ShowDocumentation()<CR>

function! ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doloher')
  else
    call feedkeys('K', 'in')
  endif
endfunction

" Vim Surrounds
" let b:surround_{char2nr('.')} = "<.>\r</.>"
" let b:surround_{char2nr(',')} = "<,>\r</,>"
" let b:surround_{char2nr('-')} = "<->\r</->"
" let b:surround_{char2nr('_')} = "<_>\r</_>"
" let b:surround_{char2nr('/')} = "</>\r</>"
" let b:surround_{char2nr('\')} = "</>\r</>"

" Plugin mappings END
" =======================================================================================================