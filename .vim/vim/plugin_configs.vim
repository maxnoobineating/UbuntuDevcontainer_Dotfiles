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
    Plug 'ludovicchabant/vim-gutentags'

call plug#end()


" ############################# "
" Plugin mapping & configuration:

" startify
" disable notimeout in startify, because the session indices selection no longer works (number pending further command indefinitely)
augroup StartifyAug
  " autocmd! FileType startify set timeout
  " " timout option can't be set locally, so resetting is required
  " autocmd! FileType *\(startify\)\@<! set notimeout
  call SetFiletypeTimeout('startify', v:true, 100)
augroup END

" startify session save
nnoremap <C-w><C-s> :SSave<CR>
let g:startify_session_persistence = 1

" function! CloseBuffersType(type)
"     for buf in range(1, bufnr('$'))
"         if getbufvar(buf, '&filetype') ==# a:type
"             execute 'bwipeout' buf
"             " echo buf
"         endif
"     endfor
" endfunction
" dunno why above don't work
let g:specialBufferType_list = ["help", "man"]
function! CloseSpecialBuffers()
    for buf in range(1, bufnr('$'))
        let l:buftype = getbufvar(buf, '&filetype')
        " if l:buftype ==# "help" || l:buftype ==# "man"
        if index(g:specialBufferType_list, l:buftype) >= 0
            execute 'bwipeout' buf
            " echo buf
        endif
    endfor
endfunction
command! CloseSB call CloseSpecialBuffers()
" let g:startify_session_before_save = [ 'silent! call CloseBuffersType("help")', 'silent! call CloseBuffersType("man")']
let g:startify_session_before_save = [ 'silent! call CloseSpecialBuffers()', 'autocmd! TabAction']

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
" fzf.vim
" search syntax: https://github.com/junegunn/fzf#search-syntax
" Initialize configuration dictionary
let g:fzf_vim = {}

" [Buffers] Jump to the existing window if possible
let g:fzf_vim.buffers_jump = 1
" [Tags] Command to generate tags file
let g:fzf_vim.tags_command = 'ctags -R'


" ##########
"FZF Buffer Delete
" author: https://www.reddit.com/r/neovim/comments/mlqyca/fzf_buffer_delete/
function! s:list_buffers()
  redir => list
  silent ls
  redir END
  return split(list, "\n")
endfunction

function! s:delete_buffers(lines)
  execute 'bdelete!' join(map(a:lines, {_, line -> split(line)[0]}))
endfunction

  " \ 'ctrl-d' : { lines -> s:delete_buffers(lines) }
  " \ 'sink*': {
  " \ 'ctrl-d' : function('s:delete_buffers'),
  " \ 'ctrl-m' : function('s:FzfPrintLines')
  " \ },
command! BD call fzf#run(fzf#wrap({
  \ 'source': s:list_buffers(),
  \ 'sink*' : function('s:delete_buffers'),
  \ 'options': '--multi --reverse --bind ctrl-a:select-all+accept'
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
  \ 'ctrl-d': function('s:delete_buffers'),
  \ 'enter': function('s:FzfAction_tabDropWrapper'),
  \ 'ctrl-t': 'tabnew',
  \ 'ctrl-m': function('s:FzfPrintLines'),
  \ 'ctrl-x': 'split',
  \ 'ctrl-v': 'vsplit' }
let g:fzf_history_dir = '~/.local/share/fzf-history'
" quickfix list (technically doesn't belong here) stepping
" in fzf popup, <alt-a> to select all, enter to add all to the quickfix list, then using this to step over them


" nnoremap <C-j> :cn<CR>
" nnoremap <C-k> :cp<CR>
nnoremap <leader>cn :silent! TabDrop cn<CR>
nnoremap <leader>cp :silent! TabDrop cp<CR>

" fzf popup mappings
nnoremap <leader>ff :Files<CR>
nnoremap <leader>fF :Files!<CR>
nnoremap <leader>fb :Buffers<CR>
nnoremap <leader>fB :Buffers!<CR>
let s:fzf_findAnything_historyFileName = 'fzf_fa'
command! -bang -nargs=* Rg
  \ call fzf#vim#grep(
  \   "rg --column --line-number --no-heading --color=always --smart-case -- ".shellescape(<q-args>), 1,
  \   fzf#wrap(s:fzf_findAnything_historyFileName, fzf#vim#with_preview('right:hidden:70%', 'ctrl-/'), <bang>0), <bang>0)
nnoremap <leader>fa :Rg<CR>
nnoremap <leader>fA :Rg!<CR>
nnoremap <leader>ft :Tags<CR>
nnoremap <leader>fT :Tags!<CR>
nnoremap <leader>fl :BLines<CR>
nnoremap <leader>fL :Lines<CR>
" alternative *man* *manpage* *:Man* with fzf search, author: "https://www.reddit.com/r/vim/comments/mg8ov7/fuzzily_searching_man_pages_using_fzfvim/"
" command! -nargs=? Apropos call fzf#run(fzf#wrap({'source': 'man -k -s 1 '.shellescape(<q-args>).' | cut -d " " -f 1', 'sink': 'tab Man', 'options': ['--preview', "MANPAGER=\"sh -c 'col -bx | batcat -l man -p'\" MANWIDTH=".(&columns/2-4).' man {}']}))
let s:fzf_findManpage_historyFileName = "fzf_fm"
command! -nargs=? Apropos call fzf#run(
  \ fzf#wrap(
    \ s:fzf_findManpage_historyFileName,
    \ {'source': 'man -k -s 1 '.shellescape(<q-args>).' | cut -d " " -f 1',
      \ 'sink': 'tab Man',
      \ 'options': ['--preview',
        \ " man {} | sh -c 'col -bx | batcat --color=always  -l man -p'",
        \ '--preview-window=nohidden,wrap,70%']}))
" command! -nargs=? Apropos call fzf#run(fzf#wrap({'source': 'man -k -s 1 '.shellescape(<q-args>).' | cut -d " " -f 1', 'sink': 'tab Man', 'options': ['--preview', "man {}"]}))
nnoremap <leader>fm :Apropos<CR>

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



" open all vim mappings table
nmap <leader>mn <plug>(fzf-maps-n)
nmap <leader>mi <plug>(fzf-maps-i)
nmap <leader>mv <plug>(fzf-maps-x)
omap <leader>mo <plug>(fzf-maps-o)
" <leader>mm implemented seperately
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
let g:ale_linters_explicit = 0
let g:ale_linters = {'javascript': [],
            \ 'python': ['flake8'],
            \ 'rust': [],
            \ 'go': [],
            \ 'bash': ['shellcheck'],
            \ 'sh': ['shellcheck'],
            \ 'tex': ['chktex'],
            \ 'c': ['gcc', 'clang'],
            \ 'cpp': ['g++', 'clang++']}
let g:ale_fixers = {'bash': ['shfmt'],
      \ 'sh': ['shfmt'],
      \ 'python': ['autoflake'],
      \ 'c': ['clang-format'],
      \ 'cpp': ['clang-format']}
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
" let g:airline#extensions#tabline#show_buffers = 1
" let g:airline_powerline_fonts = 1

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
    au BufWritePost * silent! call system('ctags ' . expand('%:p') . '2>&1 >/dev/null &')
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
\ 'coc-json',
\ 'coc-clangd',
\ 'coc-snippets'
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
nnoremap <silent> gf :let g:cocJump_previousFile=expand('%:p')<CR>:if filereadable(expand(expand('<cfile>'))) \| execute "TabDrop tabnew " . expand('<cfile>') \| endif<CR>
nnoremap <silent> gF :let g:cocJump_previousFile=expand('%:p')<CR>:if filereadable(expand(expand('<cfile>'))) \| execute "TabDrop tabnew " . expand('<cfile>') \| tabprevious \| endif<CR>
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