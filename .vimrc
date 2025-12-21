" === Basic Settings ===
set nocompatible
syntax on
set encoding=utf-8

set mouse=a
if !has("nvim")
    " To enable mouse drag for vim inside tmux
    " Neovim already works just fine
    if has("mouse_sgr")
        set ttymouse=sgr
    else
        set ttymouse=xterm2
    endif
endif

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

" === Tabs for Golang, Make and Lua ===
autocmd FileType go setlocal noexpandtab tabstop=4 shiftwidth=4 softtabstop=4
autocmd FileType make setlocal noexpandtab tabstop=4 shiftwidth=4 softtabstop=4
autocmd FileType lua setlocal noexpandtab tabstop=4 shiftwidth=4 softtabstop=4

" === 2 Spaces for Scala ===
autocmd FileType scala setlocal expandtab tabstop=2 shiftwidth=2 softtabstop=2

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
if has("termguicolors")
  set termguicolors
endif

set t_Co=256
set background=dark
for cs in ['GruberDarker', 'zaibatsu', 'industry', 'habamax']
  try
    execute 'colorscheme ' . cs
    break
  catch /^Vim\%((\a\+)\)\=:E185/
    " not found → try next
  endtry
endfor

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
nnoremap gD :ALEGoToDefinition <CR>

" === ALE Configuration ===
let g:ale_fix_on_save = 1
let g:ale_lint_on_text_changed = 'never'
let g:ale_lint_on_insert_leave = 1
let g:ale_lint_on_save = 1
let g:ale_completion_enabled = 0
let g:ale_completion_show_preview = 1
set omnifunc=ale#completion#OmniFunc

" Show hover docs in preview window
nmap <silent> K :ALEHover<CR>

let g:ale_linters = {
\   'python': ['ruff', 'pyright'],
\   'go': ['gopls', 'golangci-lint', 'go vet', 'go build'],
\   'rust': ['rustc'],
\   'c': [],
\   'h': [],
\   'asm': [],
\   'dockerfile': ['hadolint'],
\   'lua': ['lua_language_server'],
\   'scala': [],
\}

let g:ale_linters_ignore = {
\   'scala': ['*'],
\}

" Force using global pyright-langserver (important!)
let g:ale_python_pyright_use_global = 1

let g:ale_fixers = {
\   '*': ['remove_trailing_lines', 'trim_whitespace'],
\   'python': ['isort', 'ruff_format'],
\   'go': ['goimports', 'gofmt'],
\   'rust': ['rustfmt'],
\   'c': [],
\   'h': [],
\   'lua': ['stylua'],
\   'scala': ['scalafmt'],
\}

let g:ale_disable_lsp = 0

let g:ale_go_golangci_lint_executable = 'golangci-lint'
let g:ale_go_golangci_lint_options = '--fast'

" === Vim LSP Configuration ===
packadd vim-lsp

if executable('metals')
  call lsp#register_server({
        \ 'name': 'metals',
        \ 'cmd': {-> ['metals', '-Dmetals.http=off']},
        \ 'allowlist': ['scala'],
        \ })
endif

function! s:on_lsp_buffer_enabled() abort
  " Enable omni completion for Scala (Metals)
  setlocal omnifunc=lsp#complete

  " ALE-compatible keybindings (Scala only)
  nnoremap <buffer> ]a :LspNextDiagnostic<CR>
  nnoremap <buffer> [a :LspPreviousDiagnostic<CR>
  nnoremap <buffer> K  :LspHover<CR>
  nnoremap <buffer>gD  :LspDefinition<CR>
endfunction

augroup lsp_install
    au!
    " call s:on_lsp_buffer_enabled only for languages that has the server registered.
    autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END
