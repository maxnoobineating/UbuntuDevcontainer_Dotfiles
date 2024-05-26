
" filetype identification
autocmd BufNewFile,BufRead *.ipy set filetype=python

" popup menu settings
set pumheight=4

" setting combo key waiting time
" (vim don't have combination key, it only wait a while for the potential squence
" which led to a lot of keymapping causing laggy input)
" set timeoutlen=300

" Open every file as unix format (mainly for opening windows file)
set fileformats=unix,dos

" If you open this file in Vim, it'll be syntax highlighted for you.

" Vim is based on Vi. Setting `nocompatible` switches from the default
" Vi-compatibility mode and enables useful Vim functionality. This
" configuration option turns out not to be necessary for the file named
" '~/.vimrc', because Vim automatically enters nocompatible mode if that file
" is present. But we're including it here just in case this config file is
" loaded some other way (e.g. saved as `foo`, and then Vim started with
" `vim -u foo`).
set nocompatible

" Turn on syntax highlighting.
syntax enable


" Disable the default Vim startup message.
set shortmess+=I

" Show line numbers.
set number

" This enables relative line numbering mode. With both number and
" relativenumber enabled, the current line shows the true line number, while
" all other lines (above and below) are numbered relative to the current line.
" This is useful because you can tell, at a glance, what count is needed to
" jump up or down to a particular line, by {count}k to go up or {count}j to go
" down.
set relativenumber

" Always show the status line at the bottom, even if you only have one window open.
set laststatus=2

" The backspace key has slightly unintuitive behavior by default. For example,
" by default, you can't backspace before the insertion point set with 'i'.
" This configuration makes backspace behave more reasonably, in that you can
" backspace over anything.
set backspace=indent,eol,start

" By default, Vim doesn't let you hide a buffer (i.e. have a buffer that isn't
" shown in any window) that has unsaved changes. This is to prevent you from "
" forgetting about unsaved changes and then quitting e.g. via `:qa!`. We find
" hidden buffers helpful enough to disable this protection. See `:help hidden`
" for more information on this.
set hidden

" This setting makes search case-insensitive when all characters in the string
" being searched are lowercase. However, the search becomes case-sensitive if
" it contains any capital letters. This makes searching more convenient.
set ignorecase
set smartcase

" Enable searching as you type, rather than waiting till you press enter.
set incsearch

" Unbind some useless/annoying default key bindings.
" 'Q' in normal mode enters Ex mode. You almost never want this.
nmap Q <nop>

" Disable accidental opening of command history, but this actually doesn't work, fk
nnoremap q: <nop>
cnoremap q: <nop>

" Disable audible bell because it's annoying.
set noerrorbells visualbell t_vb=

" Enable mouse support. You should avoid relying on this too much, but it can
" sometimes be convenient.
set mouse+=a

" autoindentation
" set autoindent
" set smartindent <- not working with python?
filetype plugin indent on
set cindent

" An example for a vimrc file.
"
" Maintainer:	Bram Moolenaar <Bram@vim.org>
" Last change:	2019 Dec 17
"
" To use it, copy it to
"	       for Unix:  ~/.vimrc
"	      for Amiga:  s:.vimrc
"	 for MS-Windows:  $VIM\_vimrc
"	      for Haiku:  ~/config/settings/vim/vimrc
"	    for OpenVMS:  sys$login:.vimrc

" When started as "evim", evim.vim will already have done these settings, bail
" out.
if v:progname =~? "evim"
  finish
endif

" Get the defaults that most users want.
source $VIMRUNTIME/defaults.vim

if has("vms")
  set nobackup		" do not keep a backup file, use versions instead
else
  set backup		" keep a backup file (restore to previous version)
  if has('persistent_undo')
    set undofile	" keep an undo file (undo changes after closing)
  endif
endif

if &t_Co > 2 || has("gui_running")
  " Switch on highlighting the last used search pattern.
  set hlsearch
endif

" Put these in an autocmd group, so that we can delete them easily.
augroup vimrcEx
  au!

  " For all text files set 'textwidth' to 78 characters.
  autocmd FileType text setlocal textwidth=78
augroup END

" Add optional packages.
"
" The matchit plugin makes the % command work better, but it is not backwards
" compatible.
" The ! means the package won't be loaded right away but when plugins are
" loaded during initialization.
if has('syntax') && has('eval')
  packadd! matchit
endif



" Make Vim more useful
set nocompatible
" Enhance command-line completion
set wildmenu
" Allow cursor keys in insert mode
set esckeys
" Allow backspace in insert mode
set backspace=indent,eol,start
" Optimize for fast terminal connections
set ttyfast
" Add the g flag to search/replace by default
" warning: with this, replacement option g will toggle off global...
set gdefault
" Use UTF-8 without BOM
set encoding=utf-8 nobomb
" Change mapleader
let mapleader=","
" Don’t add empty newlines at the end of files
set binary
set noeol
" Centralize backups, swapfiles and undo history
set backupdir=~/.vim/backups
set directory=~/.vim/swaps
if exists("&undodir")
	set undodir=~/.vim/undo
endif

" Don’t create backups when editing files in certain directories
set backupskip=/tmp/*,/private/tmp/*

" Respect modeline in files
set modeline
set modelines=4
" Enable per-directory .vimrc files and disable unsafe commands in them
set exrc
set secure
" Enable line numbers
set number
" Enable syntax highlighting
syntax on
" Highlight current line
set cursorline
" change tabs to 4 spaces
set expandtab
set tabstop=4
set shiftwidth=4
" Show “invisible” characters
set lcs=tab:▸\ ,trail:·,eol:¬,nbsp:_
set list
" Highlight searches
set hlsearch
" Ignore case of searches
set ignorecase
" Highlight dynamically as pattern is typed
set incsearch
" Always show status line
set laststatus=2
" Enable mouse in all modes
set mouse=a
" Disable error bells
set noerrorbells
" Don’t reset cursor to start of line when moving around.
set nostartofline
" Show the cursor position
set ruler
" Don’t show the intro message when starting Vim
set shortmess=atI
" Show the current mode
set showmode
" Show the filename in the window titlebar
set title
" Show the (partial) command as it’s being typed
set showcmd
" Use relative line numbers
if exists("&relativenumber")
	set relativenumber
	au BufReadPost * set relativenumber
endif
" Start scrolling three lines before the horizontal window border
set scrolloff=3

" Strip trailing whitespace (,sw)
function! StripWhitespace()
	let save_cursor = getpos(".")
	let old_query = getreg('/')
	:%s/\s\+$//e
	call setpos('.', save_cursor)
	call setreg('/', old_query)
endfunction
noremap <leader>ws :call StripWhitespace()<CR>
" Save a file as root (,W)
noremap <leader>W :w !sudo tee % > /dev/null<CR>

" Automatic commands
if has("autocmd")
	" Enable file type detection
	filetype on
	" Treat .json files as .js
	autocmd BufNewFile,BufRead *.json setfiletype json syntax=javascript
	" Treat .md files as Markdown
	autocmd BufNewFile,BufRead *.md setlocal filetype=markdown
endif

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
                " Plug 'wakatime/vim-wakatime'

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

                " Run PlugInstall if there are missing plugins
                " https://github.com/junegunn/vim-plug/wiki/tips#automatic-installation
                autocmd VimEnter * if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
                \| PlugInstall --sync | source $MYVIMRC
                \| endif

call plug#end()


" ############################# "
" Plugin mapping & configuration:

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
nmap <leader>f :TagbarJumpNext<CR>
nmap <leader>F :TagbarJumpPrev<CR>

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
inoremap <Tab> <Plug>CocNextCompletionCustom

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

filetype plugin indent on



" #===================================================================================#
" Keybinding Mappings
inoremap <C-k> <C-o>d$
inoremap <C-b> <C-o>d^

" <C-h>/<C-l> replacing non-whitespace jump B/W
nnoremap <C-l> W
nnoremap <C-h> B

" crude auto indent
imap <expr> <Tab> (col('.') == 1) && (getline(line('.')-1) != '') ? '<C-w><CR>' : '<Plug>CocNextCompletionCustom'

" undo line with <leader>ul
nnoremap <leader>ul U
nnoremap U <C-r>

" search pattern pre-fill
noremap ;; :%s:::cg<Left><Left><Left>
noremap ;' :.s:::cg<Left><Left><Left>

" selection replacement
function! ReplaceWithInput()
    " put cursor on the head of matched pattern
    call search(@h, 'bc')
    let l:cuscol = col('.')
    let l:cusline = line('.')
    let l:text = input('Enter replacement text: ')
    let l:old_pattern = getreg('h')
    execute '.,$s/' . '\%>' . (l:cuscol-1) . 'c' . l:old_pattern . '/' . l:text . '/c'
    silent! execute '1,' . l:cusline . 's/' . l:old_pattern . '\%<' . l:cuscol . 'c/' . l:text . '/c'
endfunction
vnoremap <C-r> "hy:<C-u>call replacewithinput()<CR>
" if cursor on top of match highlights, enter replacing commands
function! IsOnMatch()
    " n: nojump, c: include first char of match, b: search behind
    " backward search (b) until the first matching head ( works for cursor on the match and on the match head (c) )
    let l:matchstart = searchpos(@/, 'Wncb')
    " forward search until the first matching tail (e), including cursor on tail (c)
    let l:matchend = searchpos(@/, 'Wnce')
    let l:matchnext = searchpos(@/, 'wnc')
    if (l:matchstart[0] != 0) && (l:matchend[0] != 0)
    return ((l:matchend[1] < l:matchnext[1]) || (l:matchnext[1] <= l:matchstart[1])) && (l:matchstart[0] == l:matchend[0])
endif
return 0
" return (col('.') < ( l:matchpos[1] + l:matchlen )) && (line('.') == l:matchpos[0])
endfunction
" nnoremap <expr> <C-r> IsOnMatch() ? ':call search(@/, "cb")<CR>v//e<CR>"hy:<C-u>call ReplaceWithInput()<CR>' : '<C-r>'
" matching replacement with @/ stored inside @h instead of copy the first match literally as the pattern
nnoremap <expr> <C-r> IsOnMatch() ? ':let @h=@/<CR>:call ReplaceWithInput()<CR>' : '<C-r>'

" select field separated by ,/;(){}[]<>
function! SepHLSearch()
    let [_, l:startLine, l:startCol, _] = getcharpos("'<")
    let [_, l:endLine, l:endCol, _] = getcharpos("'>")
    " let @/ = '\%' . l:startLine . 'l\%>' . (l:startCol-1) . 'c\_[^,(){}\[\]><+-*/; \t\n\r]\+' . '\%' . l:endLine . 'l\%<' . (l:endCol+2) . 'c'
    " let @/ = '\%>' . (l:startLine-1) . 'l\%>' . (l:startCol-1) . 'c\(\k\|\i\)\+' . '\%<' . (l:endLine+1) . 'l\%<' . (l:endCol+2) . 'c'
    let @/ = '\(\%>' . l:startLine . 'l\|\(\%>' . (l:startCol-1) . 'c\&\%' . l:startLine . 'l\)\)\(\k\|\i\)\+' . '\(\%<' . l:endLine . 'l\|\(\%<' . (l:endCol+1) . 'c\&\%' . l:endLine . 'l\)\)'
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

" Ctrl+n to select matched text
nnoremap <expr> <C-n> IsOnMatch() ? ":call search(@/, 'bc')<CR>v//e<CR>" : '//<CR>v//e<CR>'
vnoremap <C-n> v//<CR>v//e<CR>
nnoremap <expr> <C-p> IsOnMatch() ? ":call search(@/, 'bc')<CR>v//e<CR>" : '??<CR>v//e<CR>'
vnoremap <C-p> ov??<CR>v//e<CR>

" visual to the end don't enclude newline
vnoremap _ $
vnoremap - $h

" two way expansion of visual selection
vnoremap L <Esc>`<v`>loho
vnoremap H <Esc>`<v`>holo

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

" C-u C-r in insert mode for undo/redo
inoremap <C-u> <C-o>u
inoremap <C-r> <C-o><C-r>

" change 'w' word motion behaviour to excludes '_'
function! CustomWordMotion(cmd)
    let old_iskeyword=&iskeyword
    set iskeyword-=_
    execute "normal! " . a:cmd
    let &iskeyword=old_iskeyword
endfunction

nnoremap w :call CustomWordMotion('w')<CR>
nnoremap daw :call CustomWordMotion('daw')<CR>
nnoremap diw :call CustomWordMotion('diw')<CR>
" use visual mode to change word is because command will exit insert mode
" recursively linked to aw/iw below
nmap caw vawc
nmap ciw viwc
nmap cw viwc
nmap daw vawd
nmap diw viwd
nmap dw viwd
vnoremap aw :<C-u>call CustomWordMotion('gvaw')<CR>
vnoremap iw :<C-u>call CustomWordMotion('gviw')<CR>
" 'W' inplace of the original 'w' (original 'W' is everything but whitespace, quite useless)
nnoremap W w
nnoremap daW daw
nnoremap diW diw
nnoremap dW dw
nnoremap caW caw
nnoremap ciW ciw
nnoremap cW viwc
vnoremap aW aw
vnoremap iW iw


" remap capital HJKL to prevent accidental trigger
noremap <leader>j J
noremap <leader>k K
" to the first line of current context window
nnoremap K :TagbarJumpPrev<CR>
" to the last Line of current context window
nnoremap J :TagbarJumpNext<CR>
" preventing V > J/K accidentally trigger mappings
xnoremap <nowait> J j
xnoremap <nowait> K k
" H/L for navigating sentences '(' ')'
nnoremap H (
nnoremap L )

"keep visual mode after indent
vnoremap > >gv^
vnoremap < <gv^

" temporarily cancel all highlight from search, it'll come back on next search
nnoremap <Leader>v :noh<CR>

" search for selected text in visual mode
nnoremap <silent> * :let @/= '\<' . expand('<cword>') . '\>' <bar> set hls <cr>
nnoremap <silent> g* :let @/=expand('<cword>') <bar> set hls <cr>
vnoremap * y:let @/ = @"<CR>:set hlsearch<CR>

" toggle number sidebar (for more easily tmux select)
let g:signcolumn_toggle_state = 'no'
" nnoremap <expr> <f2> ":set number! relativenumber!"
nnoremap <expr> <f2> &signcolumn == 'yes' ? ":set signcolumn=no number! relativenumber!<CR>" : ":set signcolumn=yes number! relativenumber!<CR>"


" openning register panel
nnoremap <leader>r :reg<CR>

" replace default gd behaviour (if you want highlighing word under cursor, use *)
" !replaced by coc-definition
" nnoremap <expr> gd getline('.')[col('.') - 2 : col('.') + len(@/) - 2] == @/ ? "*<C-]>" : "*<C-]>n"

nnoremap o o<Esc>==
nnoremap O O<Esc>==

cmap w!! w !sudo tee % > /dev/null

" Insert mode quick deletion
" imap <C-BS> <C-W>

" pasting terminal command history
command -nargs=* Histps read !history | cut -f4- -d' ' <args>



" cursor position helper
function! IsCursorAtLastWord()
    " Save the current cursor position
    let l:save_cursor = getpos(".")

    " Find the end of the current word and get the line number
    call search('\\>', 'ce')
    let l:end_of_word_line = line(".")

    " Find the end of the line and get the line number
    call search('$', 'ce')
    let l:end_of_line_line = line(".")

    " Restore the cursor position
    call setpos('.', l:save_cursor)

    " Compare the line numbers and return the result
    return l:end_of_word_line == l:end_of_line_line
endfunction

function! IsCursorAtStart()
    return col('.') == 1
endfunction

function! IsCursorAtEnd()
    return col('.') == col('$')
endfunction

" System call for state checking
function! SystemCall(cmd)
    call system(a:cmd)
    return v:shell_error == 0
endfunction


" Clipboard settingss
" Check if X11 is installed
if SystemCall('dpkg -l | grep xorg > /dev/null 2>&1')
    " echo "X11 is installed. adopted system clipboard"
    "setting clipboard
    set clipboard=unnamedplus
    set clipboard+=unnamed
    " Use the OS clipboard by default (on versions compiled with `+clipboard`)
    " set clipboard=unnamed

    " yanking to system clipboard
    vnoremap Y "+y
    noremap YY "+yy

    noremap <nowait> p gp
    noremap <nowait> P "+gp
    noremap gp p
    noremap gP "+p
    vnoremap gP "+P
    " pls reserve mm for this
    vnoremap <nowait> p mmgPv`mo
    vnoremap <nowait> P mm"+gPv`mo

    " In visual mode, 'D' cuts the selection and puts it in the system clipboard
    vnoremap D "+x
    " In normal mode, 'DD' cuts the line and puts it in the system clipboard
    nnoremap DD "+dd
else
    " YDP store into vim unamed register, and vim-tmux-register plugin will sync them to tmux buffer
    " you can go into tmux, <Leader>b to :show-buffer and copy it down (in windows terminal, Enter also copies)
    " (because tmux select is recognized by the terminal unlike vim select)
    " echo "X11 is not installed. adopted empty clipboard (with tmux buffer sharing)"
    " yanking to system clipboard
    vnoremap Y "0y
    noremap YY "0yy

    " paste replacement should be pasted onto the block cursor (original P is paste on cursor)
    " visual mode paste should select the pasted content
    " first, fix cursor position after paste (default is - to the end if pasting no linebreak, to the begining of the next line if pasting linebreaks)
    noremap <nowait> p gp
    noremap <nowait> P "0gp
    noremap gp p
    noremap gP "0p
    vnoremap gP "0P
    " pls reserve mp for this
    vnoremap <nowait> p mpgPv`po
    vnoremap <nowait> P mp"0gPv`po

    vnoremap D "0x
    nnoremap DD "0dd
endif

" custom host yank support
let s:clipboard_export = '/mnt/c/clipboard.txt'  " change this path according to your mount point
if filereadable(s:clipboard_export)
    augroup WSLYank
        autocmd!
        " WSL
        " autocmd TextYankPost * if v:event.operator ==# 'y' | call system('echo ' . shellescape(@0) . ' > ' . s:clipboard_export) | endif
        autocmd TextYankPost * if v:event.operator =~# 'y' | call system('echo ' . shellescape(substitute(@0, '\n$', '', '')) . ' > ' . s:clipboard_export) | endif
        " autocmd TextYankPost * if v:event.operator =~# 'y' | echo 'bababooboo' . s:clipboard_export | endif
    augroup END
endif


" matching 0 as line start, - as line end
nnoremap - $
" operator pending mode
onoremap - $

" disable command-line window binding
map <nowait> q: <Nop>
nnoremap <nowait> q: <Nop>
cnoremap <nowait> q: <Nop>
nnoremap Q <Nop>

" insert mode add newline, can't map <Esc>o/O because it'll interfere with insert arrow keys below
inoremap <nowait> ^]o <Esc>o
inoremap <nowait> ^]O <Esc>O

" replace default arrow key to avoid escape sequence conflict (arrow keys will
" be translated into Esc+... and triggering "insert mode add newline" defined
" above)
inoremap <expr> <nowait> <Up> col(".") == 1 ? "<Esc>ki" : "<Esc>ka"
inoremap <expr> <Down> col(".") == 1 ? "<Esc>ji" : "<Esc>ja"
inoremap <expr> <Left> col(".") == 1 ? "<Esc>k$a" : "<Esc>i"
inoremap <expr> <Right> col(".") == col("$") ? "<Esc>j0i" : (col(".") == 1 ? "<Esc>li" : "<Esc>la")

" same in normal mode
nnoremap <nowait> <Up> k
nnoremap <Down> j
nnoremap <expr> <Left> col(".") == 1 ? "k$" : "h"
nnoremap <expr> <Right> col(".") == col("$") - 1 ? "j0" : col(".") == col("$") ? "j0" : "l"

" inoremap <expr> <C-L> IsCursorAtEnd() ? "<Cmd>echo 'true'<CR> " : "<Cmd>echo 'false'<CR>"
" insert mode delete until word end
inoremap <expr> <C-e> IsCursorAtEnd() ? "<Del>" : IsCursorAtStart() ? "<Esc>ce" : "<Esc>lce"
" insert mode delete until word begining (excludes current cursor) redundant
" inoremap <expr> <C-w> IsCursorAtStart() ? "<BS>" : IsCursorAtEnd() ? "<Esc>cb<Del>" : "<Esc>lcb"
" insert mode delete current word
" inoremap <expr> <C-c> IsCursorAtLastWord() ? (col('.') == col('$') - 1 ? "<Esc>:set virtualedit=onemore<CR>llbdw:set virtualedit=<CR>xi" : "<Esc>llbdwxi") : "<Esc>llbdwi"
imap <expr> <C-c> IsCursorAtStart() ? "<Esc>viWc" : IsCursorAtEnd() ? "<Esc>viWc" : "<Esc>lviWc"
imap <expr> <C-s> IsCursorAtStart() ? "<Esc>viwc" : IsCursorAtEnd() ? "<Esc>viwc" : "<Esc>lviwc"
" normal mode change current word
" nnoremap <expr> <C-c> IsCursorAtLastWord() ? (col('.') == col('$') - 1 ? ":set virtualedit=onemore<CR>lbdw:set virtualedit=<CR>xi" : "lbdwxi") : "lbdwi"
nmap <C-s> viwc
nmap <C-c> viWc
" normal mode delete current word
" nnoremap <expr> <C-D> IsCursorAtLastWord() ? (col('.') == col('$') - 1 ? ":set virtualedit=onemore<CR>lbdw:set virtualedit=<CR>x" : "lbdwx") : "lbdw"
nmap <C-D> viwd


" insert mode indent
inoremap <C-\> <C-T>
" insert mode deindent
" don't bind <C-[>, it'll capture any escape sequence and you can never leave insert mode...
inoremap <C-]> <C-D>
" insert mode keyword completion replace C-p with C -m
" inoremap <C-m> <C-p>
" insert mode paste from register ("" register from y)
" inoremap <C-p> <C-r>"

" next/prev buffer
noremap <leader>bn :bn<CR>
noremap <leader>bp :bp<CR>

noremap <C-Up> <C-Y>
noremap <C-Down> <C-E>

" :reload vim
command Reload source ~/.vimrc

" openup the full highlight document
command Highlight so $VIMRUNTIME/syntax/hitest.vim

"=============================================================================="
" Functions

" vim performance profiling:
" the second time toggle will save and close the file
" find the file at /tmp/vim_profile.log
" use zsh command listVimProfile to see the list
let g:vimprofilepaused = -1
" Set up an autocommand to stop profiling when exiting a file
autocmd VimLeavePre * if g:vimprofilepaused == 1 | let g:vimprofilepaused = -1 | noautocmd wqall! | endif
autocmd VimLeavePre * if g:vimprofilepaused == 0 | let g:vimprofilepaused = -1 | profile pause | noautocmd wqall! | endif
" updatetime is defaulted to 4000 ms, and CursorHold is triggered if no key input in updatetime
set updatetime=4000
" Set up an autocommand to pause profiling after 4 seconds of inactivity
autocmd CursorHold * if g:vimprofilepaused == 0 | echo 'profiling paused!' | profile pause | let g:vimprofilepaused = 1 | endif
function! ProfilingToggle()
    if g:vimprofilepaused == -1
        let g:vimprofilepaused = 0
        execute 'profile start /tmp/vim_profile.log'
        execute 'profile func *'
        execute 'profile file *'
    elseif g:vimprofilepaused == 1
        let g:vimprofilepaused = 0
        execute 'profile continue'
    else
        let g:vimprofilepaused = 1
        execute 'profile pause'
    endif
endfunction
" --------------------------------------------------------------------------------

function! OpenTempBuffer(command, sortCMD='')
    let old_reg = getreg("a")          " save the current content of register a
    let old_reg_type = getregtype("a") " save the type of the register as well
    try
        redir @a                           " redirect output to register a
        " Get the list of all key mappings silently, satisfy "Press ENTER to continue"
        silent execute a:command | call feedkeys("\<CR>")
        redir END                          " end output redirection
        vnew                               " new buffer in vertical window
        put a                              " put content of register
        setlocal buftype=nofile bufhidden=delete " set delete buffer after exiting
        " custom sort
        execute a:sortCMD
        setlocal nowrap
        setlocal nomodifiable
        nnoremap <buffer> q :bd<CR>
    finally                              " Execute even if exception is raised
        call setreg("a", old_reg, old_reg_type) " restore register a
    "trying to replace :q in the mapping pane with :bd | q for clearing buffer
    endtry
endfunction

" open mapping buffer
nnoremap <leader>m :call OpenTempBuffer('map', '%!sort -k1.4,1.4')<CR>
" open highlight buffer
nnoremap <leader>hh :call OpenTempBuffer('highlight')<CR>


" alternative to map search hk: <\m>
"function! s:ShowMaps()
"    let old_reg = getreg("a")          " save the current content of register a
"    let old_reg_type = getregtype("a") " save the type of the register as well
"    try
"        redir @a                           " redirect output to register a
"        " Get the list of all key mappings silently, satisfy "Press ENTER to continue"
"        silent map | call feedkeys("\<CR>")
"        redir END                          " end output redirection
"        vnew                               " new buffer in vertical window
"        put a                              " put content of register
"        setlocal buftype=nofile bufhidden=delete " set delete buffer after exiting
"        " Sort on 4th character column which is the key(s)
"        %!sort -k1.4,1.4
"        setlocal nowrap
"        setlocal nomodifiable
"    finally                              " Execute even if exception is raised
"        call setreg("a", old_reg, old_reg_type) " restore register a
"    "trying to replace :q in the mapping pane with :bd | q for clearing buffer
"    endtry
"endfunction
"com! ShowMaps call s:ShowMaps()      " Enable :ShowMaps to call the function
" nnoremap <Leader>m :ShowMaps<CR>

" --------------------------------------------------------------------------------
" --------------------------------------------------------------------------------
" failure command when pattern matched for recursive macro fail condition
" use: `:QLineCheck PATTERN` inside recording to stop the macro when pattern
" is matched.

function! s:QLstop(pattern)
	echo a:pattern
  let l:current_line = getline('.')
  if match(l:current_line, a:pattern) != -1
		echoerr "End Of Recursive Macro"
  endif
endfunction
command! -nargs=1 QLstop call s:QLstop(<f-args>)

" function! _test()
"   let l:current_line = getline('.')
" 	if match(l:current_line, 'END') != -1
" 		echoerr "End Of Recursive Macro"
"   endif
" endfunction

" block cursor for windows terminal
" https://github.com/microsoft/terminal/issues/4335
if &term =~ '^xterm'
  " enter vim
  autocmd VimEnter * silent !echo -ne "\e[2 q"

  " Change cursor depending on mode, like in nvim
  " Insert mode
    let &t_SI = "\<Esc>[6 q"
  " Replace mode
    let &t_SR = "\<Esc>[4 q"
  " Normal mode
    let &t_EI = "\<Esc>[2 q"
  " 1 or 0 -> blinking block
  " 2 -> solid block
  " 3 -> blinking underscore
  " 4 -> solid underscore
  " Recent versions of xterm (282 or above) also support
  " 5 -> blinking vertical bar
  " 6 -> solid vertical bar

  " leave vim
  autocmd VimLeave * silent !echo -ne "\e[5 q"
endif


" ############################# "
" suffix section

" Set SignColumn background color to light gray
" 256 xterm color see: https://www.ditig.com/publications/256-colors-cheat-sheet
highlight SignColumn ctermbg=0
highlight CocMenuSel ctermfg=152 ctermbg=132
highlight CocFloating ctermfg=96 ctermbg=0
highlight TabLineSel  term=underline,reverse cterm=underline,reverse ctermfg=131 ctermbg=53 gui=bold
highlight TabLine term=underline cterm=underline ctermfg=97 ctermbg=0 gui=underline guibg=DarkGrey
highlight TabLineFill term=underline cterm=underline ctermfg=97 ctermbg=0 gui=reverse
highlight Comment term=italic cterm=italic ctermfg=181 guifg=#80a0ff
highlight Cursor cterm=reverse ctermbg=12
highlight Visual term=reverse cterm=reverse ctermfg=132 ctermbg=123 guibg=DarkGrey
highlight VertSplit ctermfg=97 ctermbg=0 gui=reverse
highlight SpecialKey term=bold cterm=bold ctermfg=11 ctermbg=8 guifg=Cyan
augroup HITABFILL
    autocmd!
    autocmd User AirlineModeChanged highlight airline_warning ctermfg=232 ctermbg=167
    autocmd User AirlineModeChanged highlight airline_warning_bold ctermfg=232 ctermbg=167
    autocmd User AirlineModeChanged highlight airline_warning_inactive ctermfg=232 ctermbg=167
    autocmd User AirlineModeChanged highlight airline_warning_inactive_bold ctermfg=232 ctermbg=167
    " |AirlineAfterInit|    after plugin is initialized, but before the statusline is replaced
    " |AirlineAfterTheme|   after theme of the statusline has been changed
    " |AirlineToggledOn|    after airline is activated and replaced the statusline
    " |AirlineToggledOff|   after airline is deactivated and the statusline is restored to the original
    " |AirlineModeChanged|  The mode in Vim changed.
augroup END


" disable autocomment-out of newlines
" putting this at the end to avoid formatoptions resetting
autocmd BufRead,BufNewFile,FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o