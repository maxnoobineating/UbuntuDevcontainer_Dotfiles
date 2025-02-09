" completion
set pumwidth=10
set completeopt+=menuone
" XXX 
" set completeopt+=noselect
set completepopup=height:4,width:15,highlight:CocMenuSel,border:off

" default shell to zsh
set shell=/bin/zsh

" line wrapping
set wrap linebreak breakindent

" global variables
let g:env_shellscript_path = fnamemodify("~/.vim/vim", ':p') . 'shellscript/'
if !isdirectory(g:env_shellscript_path)
  call mkdir(g:env_shellscript_path)
endif
let &path.="," . $CPATH->split(':')->join(',')

" tabline settings
set showtabline=2 " always show tabline even for 1 tab

" folding method
set foldmethod=syntax

" update time for more frequent gitgutter update
set updatetime=500

" jump to existing buffer first
set switchbuf=usetab,useopen,newtab

" filetype identification
autocmd BufNewFile,BufRead *.ipy set filetype=python

" popup menu settings
set pumheight=4


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
" set smartindent " <- not working with python?
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

" change tabs to 2 spaces
set expandtab
set tabstop=2
set shiftwidth=2
" File type specific settings
augroup filetype_indent
  autocmd!
  autocmd BufEnter *.vim setlocal expandtab tabstop=2 shiftwidth=2
  " Python specific settings
  autocmd BufEnter *.py setlocal expandtab tabstop=4 shiftwidth=4
  " JavaScript specific settings
  autocmd BufEnter *.js setlocal expandtab tabstop=2 shiftwidth=2
  " C specific settings
  autocmd BufEnter *.c setlocal expandtab tabstop=2 shiftwidth=2
  autocmd BufEnter *.cpp setlocal expandtab tabstop=2 shiftwidth=2
  autocmd BufEnter *.h setlocal expandtab tabstop=2 shiftwidth=2
  autocmd BufEnter * if !IsSpecialBuffer(&buftype) && !IsSpecialFileType(&filetype)
        \ | execute 'IndentLinesReset'
        \ | endif
augroup END

" Show “invisible” characters
" set lcs=tab:▸\ ,trail:·,eol:¬,nbsp:_
set lcs=tab:\ \ 
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

" Automatic commands
if has("autocmd")
	" Enable file type detection
	filetype on
	" Treat .json files as .js
	autocmd BufNewFile,BufRead *.json setfiletype json syntax=javascript
	" Treat .md files as Markdown
	autocmd BufNewFile,BufRead *.md setlocal filetype=markdown
endif

filetype plugin indent on

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