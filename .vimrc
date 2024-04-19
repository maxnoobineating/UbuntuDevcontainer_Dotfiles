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
syntax on

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
nmap Q <Nop>

" Disable audible bell because it's annoying.
set noerrorbells visualbell t_vb=

" Enable mouse support. You should avoid relying on this too much, but it can
" sometimes be convenient.
set mouse+=a


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


" Use the Solarized Dark theme
set background=dark
colorscheme solarized
let g:solarized_termtrans=1

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

" Strip trailing whitespace (,ss)
function! StripWhitespace()
	let save_cursor = getpos(".")
	let old_query = getreg('/')
	:%s/\s\+$//e
	call setpos('.', save_cursor)
	call setreg('/', old_query)
endfunction
noremap <leader>ss :call StripWhitespace()<CR>
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


let g:ale_disable_lsp = 1
let g:ale_linters_explicit = 1
let g:ale_linters = {'javascript': [], 'python': ['flake8'], 'rust': [], 'go': [], 'bash': ['shellcheck'], 'sh': ['shellcheck'], 'tex': ['chktex']}
let g:ale_fixers = {'bash': ['shfmt'], 'sh': ['shfmt']}
let g:ale_sign_error = '>>'
let g:ale_sign_warning = '--'
let g:ale_lint_on_text_changed = 'always'


call plug#begin('~/.vim/plugged')

				let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
				if empty(glob(data_dir . '/autoload/plug.vim'))
					silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
					autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
				endif
				Plug 'mhinz/vim-startify'

                Plug 'dense-analysis/ale'

				Plug 'neoclide/coc.nvim', { 'branch': 'release' }
				Plug 'easymotion/vim-easymotion'

				Plug 'jiangmiao/auto-pairs'

                Plug 'wakatime/vim-wakatime'

                Plug 'vim-scripts/TaskList.vim'

                Plug 'preservim/nerdtree'

                Plug 'tmhedberg/simpylfold'

                Plug 'majutsushi/tagbar'

                Plug 'xolox/vim-easytags'

                Plug 'xolox/vim-misc'

                Plug 'tpope/vim-commentary'

                Plug 'tpope/vim-surround'

                Plug 'roxma/vim-tmux-clipboard'

call plug#end()

" Plugin mapping:
"
" tagbar
nmap <F8> :TagbarToggle fjc<CR>

" NerdTree
nnoremap <leader>n :NERDTreeFocus<CR>

" easyfold, unfold all after fold creation (every new session)
autocmd BufWinEnter * silent! :%foldopen!

" Plugin mappings END


filetype plugin indent on



" -------- "
" MAPPINGS "
" -------- "

" openning register panel
nnoremap <leader>r :reg<CR>

" replace default gd behaviour (if you want highlighing word under cursor, use *)
nnoremap gd <C-]>

nnoremap o o<Esc>
nnoremap O O<Esc>

cmap w!! w !sudo tee % > /dev/null

" Insert mode quick deletion
" imap <C-BS> <C-W>

" pasting terminal command history
command -nargs=* Histps read !history | cut -f4- -d' ' <args>

" navigate coc linter message
nmap <silent> <C-j> <Plug>(coc-diagnostic-next-error)
nmap <silent> <C-k> <Plug>(coc-diagnostic-prev-error)
" opening :CocList diagnostic
function! s:Err()
    CocList diagnostics
endfunction
com! Err call s:Err()      " Enable :ShowMaps to call the function

nnoremap <Leader>e :Err<CR>


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

function! IsCurosrAtStart()
    return col('.') == 1
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
    noremap P "+p
    " In visual mode, 'D' cuts the selection and puts it in the system clipboard
    vnoremap D "+x
    " In normal mode, 'DD' cuts the line and puts it in the system clipboard
    nnoremap DD "+dd
else
    " echo "X11 is not installed. adopted empty clipboard (with tmux buffer sharing)"
    " yanking to system clipboard
    vnoremap Y "0y
    noremap YY "0yy
    noremap P "0p
    " In visual mode, 'D' cuts the selection and puts it in the system clipboard
    vnoremap D "0x
    " In normal mode, 'DD' cuts the line and puts it in the system clipboard
    nnoremap DD "0dd
endif


noremap - $

nnoremap q: <nop>

" insert mode add newline
inoremap \\eo A<CR>
inoremap \\eO I<CR>k


" replace default arrow key to avoid escape sequence conflict (arrow keys will
" be translated into Esc+... and triggering "insert mode add newline" defined
" above)
inoremap <expr> <Up> col(".") == 1 ? "<Esc>ki" : "<Esc>ka"
inoremap <expr> <Down> col(".") == 1 ? "<Esc>ji" : "<Esc>ja"
inoremap <expr> <Left> col(".") == 1 ? "<Esc>k$a" : "<Esc>i"
inoremap <expr> <Right> col(".") == col("$") ? "<Esc>j0i" : (col(".") == 1 ? "<Esc>li" : "<Esc>la")

" same in normal mode
nnoremap <Up> k
nnoremap <Down> j
nnoremap <expr> <Left> col(".") == 1 ? "k$" : "h"
nnoremap <expr> <Right> col(".") == col("$") - 1 ? "j0" : col(".") == col("$") ? "j0" : "l"


" insert mode delete until word end
inoremap <C-e> <Esc>ldei
" insert mode delete until word begining (includes words on cursor)
inoremap <C-b> <Esc>lxdbi
" insert mode delete current word
" inoremap <expr> <C-c> IsCursorAtLastWord() ? (col('.') == col('$') - 1 ? "<Esc>:set virtualedit=onemore<CR>llbdw:set virtualedit=<CR>xi" : "<Esc>llbdwxi") : "<Esc>llbdwi"
inoremap <expr> <C-c> IsCurosrAtStart() ? "<Esc>viwdi" : "<Esc>lviwdi"
" normal mode change current word
" nnoremap <expr> <C-c> IsCursorAtLastWord() ? (col('.') == col('$') - 1 ? ":set virtualedit=onemore<CR>lbdw:set virtualedit=<CR>xi" : "lbdwxi") : "lbdwi"
nnoremap <C-c> viwc
" normal mode delete current word
" nnoremap <expr> <C-D> IsCursorAtLastWord() ? (col('.') == col('$') - 1 ? ":set virtualedit=onemore<CR>lbdw:set virtualedit=<CR>x" : "lbdwx") : "lbdw"
nnoremap <C-D> viwd


" insert mode indent
inoremap <C-\> <C-T>
" insert mode deindent
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

" Ctrl+n to select matched text
nnoremap <C-n> h//<CR>vh//e<CR>
vnoremap <C-n> vh//<CR>vh//e<CR>

" :reload vim
command Reload source ~/.vimrc

" --------------------------------------------------------------------------------
" alternative to map search hk: <\m>
function! s:ShowMaps()
  let old_reg = getreg("a")          " save the current content of register a
  let old_reg_type = getregtype("a") " save the type of the register as well
try
  redir @a                           " redirect output to register a
  " Get the list of all key mappings silently, satisfy "Press ENTER to continue"
  silent map | call feedkeys("\<CR>")
  redir END                          " end output redirection
  vnew                               " new buffer in vertical window
  put a                              " put content of register
	setlocal buftype=nofile bufhidden=delete " set delete buffer after exiting
  " Sort on 4th character column which is the key(s)
  %!sort -k1.4,1.4
	setlocal nowrap
  setlocal nomodifiable
finally                              " Execute even if exception is raised
  call setreg("a", old_reg, old_reg_type) " restore register a

	"trying to replace :q in the mapping pane with :bd | q for clearing buffer
endtry
endfunction
com! ShowMaps call s:ShowMaps()      " Enable :ShowMaps to call the function

nnoremap \m :ShowMaps<CR>

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