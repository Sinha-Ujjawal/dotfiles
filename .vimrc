" === Basic Settings ===
set nocompatible
syntax on
set encoding=utf-8

" === Search ===
set ignorecase
set smartcase
set incsearch
set hlsearch

" === Indentation: Default to 4 spaces ===
set tabstop=4
set shiftwidth=4
set expandtab
set autoindent

" === Tabs for Golang ===
autocmd FileType go setlocal noexpandtab tabstop=4 shiftwidth=4 softtabstop=4

" === Navigation & Display ===
set path+=**
set wildmenu
set scrolloff=5
set nu rnu
set belloff=all
set backspace=indent,eol,start

" === Folds ===
set foldmethod=indent
set nofoldenable

" === Colors ===
set t_Co=256
colorscheme industry

" === Grep ===
set gp=grep\ -n

" === Custom Commands ===
command! QBuffers call setqflist(map(filter(range(1, bufnr('$')), 'buflisted(v:val)'), '{"bufnr":v:val}'))

" === Snippet Insertion ===
nnoremap ,mit :-1read $HOME/.vim/.skeleton.mit<CR>ggwcf>

" === Toggle Color Column ===
function! ToggleColorColumn(value)
    if &colorcolumn != ''
        set colorcolumn=
    else
        execute 'set colorcolumn=' . a:value
    endif
endfunction

" === Prepend with line numbers ===
function! NumberLines(...)
    let start = a:0 > 0 ? a:1 : 1 "a:0 is the count of args passed
    let n = line('.') - line("'<") + start
    let orig = getline('.')
    call setline('.', n . '. ' . orig)
endfunction

" === Shortcuts ===
nnoremap ,da ggdG                                " delete all
nnoremap ,ca ggy"*G                              " copy all to system clipboard
nnoremap ,ta :%s/\s\+$//<CR>                     " trim trailing whitespace
nnoremap ,r :set nu rnu <CR>                     " relative line numbers
nnoremap ,n :set nornu nu <CR>                   " absolute line numbers
nnoremap ,cc :call ToggleColorColumn(120) <CR>   " toggle 120-col guide

" === ALE Navigation ===
nnoremap ]a :ALENext <CR>
nnoremap [a :ALEPrevious <CR>

" === ALE Configuration ===
let g:ale_fix_on_save = 1
let g:ale_lint_on_text_changed = 'never'
let g:ale_lint_on_insert_leave = 1
let g:ale_lint_on_save = 1

let g:ale_linters = {
\   'python': ['ruff'],
\   'go': ['gopls', 'golangci-lint', 'go vet', 'go build'],
\}

let g:ale_fixers = {
\   '*': ['remove_trailing_lines', 'trim_whitespace'],
\   'python': ['ruff_format', 'isort'],
\   'go': ['goimports', 'gofmt'],
\}

let g:ale_go_golangci_lint_executable = 'golangci-lint'
let g:ale_go_golangci_lint_options = '--fast'

" === Vim-AI Plugin (Local Ollama Integration) ===
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

" === Dummy Key for Local LLM ===
let $OPENAI_API_KEY = 'dummy-key-for-local-ollama'
