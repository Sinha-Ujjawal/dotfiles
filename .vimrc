let g:is_vim8 = v:version >= 800
let g:has_packages = has('packages') && g:is_vim8

" === Basic Settings ===
set nocompatible
syntax on
set encoding=utf-8
set hidden " To enable buffer switching without the necessaity to save.
set laststatus=2 " To show status bar

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

" Check if running in Wayland and wl-clipboard is installed
if !empty($WAYLAND_DISPLAY) && executable('wl-copy') && executable('wl-paste')
    " Yank visual selection to Wayland clipboard
    xnoremap "*y y:call system("wl-copy", @")<cr>
    xnoremap "+y y:call system("wl-copy", @")<cr>

    " Paste from Wayland clipboard
    " substitute() removes potential trailing carriage returns (\r) often added by GTK apps
    nnoremap "*p :let @"=substitute(system("wl-paste --no-newline"), '\r', '', 'g')<cr>p
    nnoremap "+p :let @"=substitute(system("wl-paste --no-newline"), '\r', '', 'g')<cr>p
endif

" === Search ===
set ignorecase
set smartcase
set incsearch
set hlsearch

" Get escaped search pattern from visual selection (supports multi-line)
function! s:GetVisualPattern() abort
    " Save register and clipboard
    let l:save_reg  = @"
    let l:save_clip = &clipboard
    set clipboard=

    " Yank visual selection
    silent normal! gvy
    let l:pattern = @"

    " Restore register and clipboard
    let @" = l:save_reg
    let &clipboard = l:save_clip

    " Remove trailing newline
    let l:pattern = substitute(l:pattern, '\n\%$', '', '')

    " Escape regex characters
    let l:pattern = escape(l:pattern, '\.^$~[]*\/')

    " Convert newlines to multi-line whitespace match
    let l:pattern = substitute(l:pattern, '\n', '\\_s\\+', 'g')

    return l:pattern
endfunction

" Prompt for directory, defaulting to cwd
function! s:PromptDir() abort
    let l:dir = input('Search directory: ', getcwd(), 'dir')
    return empty(l:dir) ? '' : l:dir
endfunction

function! SearchInBuffer() range
    let l:pattern = s:GetVisualPattern()
    if empty(l:pattern)
        return
    endif

    let @/ = l:pattern
    normal! n
endfunction

function! SearchInFolder() range
    let l:pattern = s:GetVisualPattern()
    if empty(l:pattern)
        return
    endif

    let l:dir = s:PromptDir()
    if empty(l:dir)
        echo "Search cancelled"
        return
    endif

    " Clear old results
    call setqflist([])

    " Recursive search
    execute 'vimgrep /' . l:pattern . '/j ' . fnameescape(l:dir) . '/**/*'

    copen
endfunction

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
nnoremap ,mit :-1read $HOME/.vim/snippets/mit<CR>ggwcf>
function! InsertDocSnippet()
  let l:ft = &filetype
  let l:snippet = expand('~/.vim/snippets/' . l:ft . '.doc')

  if filereadable(l:snippet)
    execute 'read ' . fnameescape(l:snippet)
    normal! k
  else
    echo 'No doc snippet for ' . l:ft
  endif
endfunction
nnoremap ,doc :call InsertDocSnippet()<CR>

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
nnoremap ,da ggdG                                                    " delete all
nnoremap ,ca ggy"*G                                                  " copy all to system clipboard
nnoremap ,ta :%s/\s\+$//<CR>                                         " trim trailing whitespace
nnoremap ,r :set nu rnu <CR>                                         " relative line numbers
nnoremap ,n :set nornu nu <CR>                                       " absolute line numbers
nnoremap ,cc :call ToggleColorColumn(120) <CR>                       " toggle 120-col guide
nnoremap ,cf :let @+=expand("%:p") <bar> let @"=expand("%:p") <CR>   " copies the current buffers absolute location to '+' and '"' registers
nnoremap ,cr :let @+=expand("%")   <bar> let @"=expand("%")   <CR>   " copies the current buffers relative location to '+' and '"' registers
nnoremap ,s :<C-u>call gitblame#echo()<CR>                           " showing git blame output in status bar (from https://github.com/zivyangll/git-blame.vim?tab=readme-ov-file#please-setting-bindings)

" === Loading Packages
let s:vim_dir = expand('~/.vim')
if has('nvim')
    let &packpath = s:vim_dir . ',' . &packpath
endif
" Loading Packages
if g:has_packages
    silent! packadd ale
    silent! packadd vim-lsp
else
    for dir in split(globpath(s:vim_dir, 'pack/*/start/*'), '\n')
        if isdirectory(dir)
            execute 'set runtimepath+=' . dir
        endif
    endfor
endif
" Loading Helptags
for dir in split(globpath(s:vim_dir, 'pack/*/start/*/doc'), '\n')
    if isdirectory(dir)
        execute 'silent! helptags ' . dir
    endif
endfor

" === ALE Configuration ===
nnoremap ]a :ALENext <CR>
nnoremap [a :ALEPrevious <CR>
nnoremap gD :ALEGoToDefinition <CR>

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
\   'scala': [],
\}

let g:ale_disable_lsp = 0

let g:ale_go_golangci_lint_executable = 'golangci-lint'
let g:ale_go_golangci_lint_options = '--fast'

" === Vim LSP Configuration ===
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

" Special yank useful when ssh into a server
" Reference: https://andrewbrookins.com/technology/copying-to-the-ios-clipboard-over-ssh-with-control-codes/
" copy to attached terminal using the yank(1) script:
" https://github.com/sunaku/home/blob/master/bin/yank
" Function to pipe text to the 'yank' utility
function! Yank(text) abort
  " We wrap 'yank' in 'bash -ci' so Vim can find your .bashrc function
  " Alternatively, if you saved 'yank' as a file in /usr/local/bin,
  " you can just use 'yank'
  let l:cmd = "bash -ci 'yank'"
  let l:escape = system(l:cmd, a:text)

  if v:shell_error
    echoerr l:escape
  else
    " Write the escape sequence directly to the terminal TTY
    " This bypasses Vim's internal clipboard and talks to iTerm2
    call writefile([l:escape], '/dev/tty', 'b')
  endif
endfunction

" Map Ctrl+c in Visual mode to yank the selection to Mac
vnoremap <silent> <C-c> "0y:call Yank(@0)<CR>
