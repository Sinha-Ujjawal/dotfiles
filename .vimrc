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
set nu rnu

" disable bell
set belloff=all

" enable backspace
set backspace=indent,eol,start

" Netrw
" let g:netrw_banner       = 0  " hide the netrw banner
" let g:netrw_liststyle    = 3  " tree view
" let g:netrw_winsize      = 20 " set netrw size to 20%
" let g:netrw_browse_split = 4  " open file in a seperate buffer

" colors
set t_Co=256 " allow full range of 256 colors

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

function! ToggleColorColumn(value)
    if &colorcolumn != ''
        set colorcolumn=
    else
        execute 'set colorcolumn=' . a:value
    endif
endfunction

" shortcuts
" delete entire content of current buffer, and copy into the default (0) register
nnoremap ,da ggdG
" copy entire content of current buffer into * register
nnoremap ,ca ggy"*G
" trim ending spaces from each lines
nnoremap ,ta :%s/\s\+$//<CR>
" " formats current buffer using jq
" nnoremap ,jq :%! jq .<CR>
" set relative number
nnoremap ,r :set nu rnu <CR>
" set number
nnoremap ,n :set nornu nu <CR>
" toggle column color
nnoremap ,cc :call ToggleColorColumn(120) <CR>

" colorscheme
" colorscheme habamax
" colorscheme desert
colorscheme industry

" Ale settings
nnoremap ]a :ALENext <CR>
nnoremap [a :ALEPrevious <CR>

" " Ale linters and fixers
let g:ale_linters = {
\ 'python': ['ruff'],
\}
let g:ale_fixers = {
\ '*': ['remove_trailing_lines', 'trim_whitespace'],
\ 'python': ['ruff_format'],
\}
let g:ale_fix_on_save = 1

" " Ale Vim-AI
let g:vim_ai_complete = {
\  "engine": "chat",
\  "options": {
\    "model": "qwen2.5-coder:3b",
\    "endpoint_url": "http://localhost:11434/v1/chat/completions",
\    "max_tokens": 1000,
\    "temperature": 0.1,
\    "request_timeout": 20,
\    "initial_prompt": "You are a coding assistant. Provide clean, concise code with minimal comments. Only add comments when absolutely necessary for complex logic. Prefer self-documenting code over excessive comments.",
\  },
\  "ui": {
\    "paste_mode": 1,
\  },
\}

let g:vim_ai_chat = {
\  "options": {
\    "model": "qwen2.5-coder:3b",
\    "endpoint_url": "http://localhost:11434/v1/chat/completions",
\    "max_tokens": 1000,
\    "temperature": 0.1,
\    "request_timeout": 20,
\  },
\}

let g:vim_ai_edit = {
\  "engine": "chat",
\  "options": {
\    "model": "qwen2.5-coder:3b",
\    "endpoint_url": "http://localhost:11434/v1/chat/completions",
\    "max_tokens": 1000,
\    "temperature": 0.1,
\    "request_timeout": 20,
\    "initial_prompt": "Provide concise code with minimal comments. Focus on clean, readable code rather than explanatory comments.",
\  },
\}

" Set environment variable for API key (required by the plugin)
let $OPENAI_API_KEY = 'dummy-key-for-local-ollama'
