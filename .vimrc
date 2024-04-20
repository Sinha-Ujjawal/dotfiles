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

" shortcuts
" delete entire content of current buffer, and copy into the default (0) register
nnoremap ,da ggdG
" copy entire content of current buffer into * register
nnoremap ,ca ggy"*G

call plug#begin()
" The default plugin directory will be as follows:
"   - Vim (Linux/macOS): '~/.vim/plugged'
"   - Vim (Windows): '~/vimfiles/plugged'
"   - Neovim (Linux/macOS/Windows): stdpath('data') . '/plugged'
" You can specify a custom plugin directory by passing it as the argument
"   - e.g. `call plug#begin('~/.vim/plugged')`
"   - Avoid using standard Vim directory names like 'plugin'

Plug 'prabirshrestha/vim-lsp'
Plug 'mattn/vim-lsp-settings'


" Initialize plugin system
" - Automatically executes `filetype plugin indent on` and `syntax enable`.
call plug#end()
" You can revert the settings after the call like so:
"   filetype indent off   " Disable file-type-specific indentation
"   syntax off            " Disable syntax highlighting

function! s:on_lsp_buffer_enabled() abort
    setlocal omnifunc=lsp#complete
    setlocal signcolumn=yes
    if exists('+tagfunc') | setlocal tagfunc=lsp#tagfunc | endif
    nmap <buffer> gd <plug>(lsp-definition)
    nmap <buffer> gs <plug>(lsp-document-symbol-search)
    nmap <buffer> gS <plug>(lsp-workspace-symbol-search)
    nmap <buffer> gr <plug>(lsp-references)
    nmap <buffer> gi <plug>(lsp-implementation)
    nmap <buffer> gt <plug>(lsp-type-definition)
    nmap <buffer> <leader>rn <plug>(lsp-rename)
    nmap <buffer> [g <plug>(lsp-previous-diagnostic)
    nmap <buffer> ]g <plug>(lsp-next-diagnostic)
    nmap <buffer> K <plug>(lsp-hover)
    nnoremap <buffer> <expr><c-Down> lsp#scroll(+4)
    nnoremap <buffer> <expr><c-Up> lsp#scroll(-4)

    let g:lsp_format_sync_timeout = 1000
    autocmd! BufWritePre *.rs,*.go call execute('LspDocumentFormatSync')

" refer to doc to add more commands
endfunction


augroup lsp_install
    au!
    " call s:on_lsp_buffer_enabled only for languages that has the server registered.
    autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END
