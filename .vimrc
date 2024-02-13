" enter the current millenium
set nocompatible

" setting syntax highlighting on
syntax on

" settings for help in searching text
set ignorecase
set smartcase
set incsearch

" show existing tab with 4 spaces width
set tabstop=4
" when indenting with '>', use 4 spaces width
set shiftwidth=4
" On pressing tab, insert 4 spaces
set expandtab

" set search path to include current directory and sub-directories
set path+=**

" highlight search text
set hlsearch

" When 'wildmenu' is on, command-line completion operates in an enhanced
" mode.  On pressing 'wildchar' (usually <Tab>) to invoke completion,
" the possible matches are shown.
set wildmenu

" sticking the scroll to 5 lines from both top and bottom
set scrolloff=5

" set relative number and number
set relativenumber
set number 

" disable bell
set belloff=all

" enable backspace
set backspace=indent,eol,start

" set color scheme to `desert`
colorscheme desert
