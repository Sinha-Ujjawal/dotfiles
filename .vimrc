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
" auto indent
set autoindent

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

" show line numbers
set number 

" disable bell
set belloff=all

" enable backspace
set backspace=indent,eol,start

" Netrw
let g:netrw_banner       = 0  " hide the netrw banner
let g:netrw_liststyle    = 3  " tree view
let g:netrw_winsize      = 20 " set netrw size to 20%
let g:netrw_browse_split = 4  " open file in a seperate buffer

" colors
set t_Co=256 " allow full range of 256 colors
colorscheme habamax

" folds
set foldmethod=indent " set the foldmethod to indent by default
set nofoldenable      " turn off all the folds

" to enable utf-8 encoding
set encoding=utf-8

" fast grep in vim
set gp=grep\ -n

" https://vi.stackexchange.com/questions/2121/how-do-i-have-buffers-listed-in-a-quickfix-window-in-vim
command! QBuffers call setqflist(map(filter(range(1, bufnr('$')), 'buflisted(v:val)'), '{"bufnr":v:val}'))

" snippets
nnoremap ,mit :-1read $HOME/.vim/.skeleton.mit<CR>ggwcf>
