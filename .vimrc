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

" === Command-Line-Window Settings ===
" " Open command-line-window when pressing : or / or ?
" nnoremap : q:i
" nnoremap / q/i
" nnoremap ? q?i
set cmdwinheight=10
augroup CmdWinCustom
    autocmd!
    " Handle all command-line windows
    autocmd CmdwinEnter * setlocal wrap linebreak nolist number relativenumber
augroup END

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

function! FindQf(cmd)
    " Capture shell output as a list
    let l:lines = split(system(a:cmd), '\n')

    " Append :1:1 to every entry
    call map(l:lines, 'v:val . ":1:1"')

    " Load into quickfix and open window
    cexpr l:lines
    copen
endfunction
" Usage:
" :FindQf ls
" :FindQf find . -name "*.py"
command! -nargs=+ FindQf call FindQf(<q-args>)

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

" Listing files to quickfix
function! ListFilesToQuickfix()
    " 1. Decide the shell command based on environment
    let l:is_git = system('git rev-parse --is-inside-work-tree')
    if v:shell_error == 0
        " Git branch: Chaining commands is faster than multiple system calls
        let l:cmd = 'git ls-files --recurse-submodules -c && git ls-files -o --exclude-standard'
    elseif has('win32') || has('win64')
        " Windows branch: Use /a-d to skip folders but include hidden files
        let l:cmd = 'dir /s /b /a-d'
    else
        " Unix branch: Standard find
        let l:cmd = 'find . -type f'
    endif

    " 2. Populate Quickfix via internal C-engine (Avoids slow VimScript loops)
    let l:old_efm = &errorformat
    set errorformat=%f

    " cgetexpr executes the command and parses the entire string at once
    execute 'cgetexpr system("' . l:cmd . '")'

    " 3. Post-processing (Filtering)
    " We use internal filter() which is significantly faster than for-loops
    let l:qf = getqflist()
    call filter(l:qf, 'v:val.text !~# "^\.git[/\\]" && bufname(v:val.bufnr) !~# "\.git[/\\]"')
    call setqflist(l:qf, 'r')

    let &errorformat = l:old_efm
    copen
    echo "Found " . len(getqflist()) . " files."
endfunction
nnoremap ,f :call ListFilesToQuickfix()<CR>

" === Comment Lines ===
" Map filetypes to [OpeningTag, ClosingTag]
" Use an empty string '' if no closing tag is required.
let s:comment_map = {
    \ 'c'         : ['//'   , ''    ],
    \ 'cpp'       : ['//'   , ''    ],
    \ 'python'    : ['#'    , ''    ],
    \ 'vim'       : ['"'    , ''    ],
    \ 'lua'       : ['--'   , ''    ],
    \ 'javascript': ['//'   , ''    ],
    \ 'css'       : ['/*'   , ' */' ],
    \ 'html'      : ['<!-- ', ' -->'],
    \ 'rust'      : ['//'   , ''    ]
    \ }

function! ToggleComment() range
    let l:ft = &filetype
    if !has_key(s:comment_map, l:ft) | return | endif

    let l:open = s:comment_map[l:ft][0]
    let l:close = s:comment_map[l:ft][1]

    " 2. Calculate minimum indentation for vertical alignment
    let l:min_indent = 999
    for l:lnum in range(a:firstline, a:lastline)
        let l:line = getline(l:lnum)
        if l:line =~ '^\s*$' | continue | endif
        let l:indent = indent(l:lnum)
        if l:indent < l:min_indent | let l:min_indent = l:indent | endif
    endfor
    if l:min_indent == 999 | let l:min_indent = 0 | endif

    " 3. Determine if the block is already commented
    let l:all_commented = 1
    let l:open_regex = '^\s\{' . l:min_indent . '\}' . escape(l:open, '/*^$')
    for l:lnum in range(a:firstline, a:lastline)
        let l:line = getline(l:lnum)
        if l:line =~ '^\s*$' | continue | endif
        if l:line !~ l:open_regex
            let l:all_commented = 0
            break
        endif
    endfor

    " 4. Apply toggle with vertical alignment
    let l:esc_open = escape(l:open, '/*^$')
    let l:esc_close = escape(l:close, '/*^$')

    if l:all_commented
        " Remove opening tag at min_indent and optional closing tag at line end
        for l:lnum in range(a:firstline, a:lastline)
            let l:line = getline(l:lnum)
            " Remove opening tag and one trailing space if it exists
            let l:line = substitute(l:line, '^\(\s\{' . l:min_indent . '\}\)' . l:esc_open . '\s\?', '\1', '')
            " Remove closing tag and one leading space if it exists
            if l:close != ''
                let l:line = substitute(l:line, '\s\?' . l:esc_close . '\s*$', '', '')
            endif
            call setline(l:lnum, l:line)
        endfor
    else
        " Add opening tag at min_indent and closing tag at end of line
        for l:lnum in range(a:firstline, a:lastline)
            let l:line = getline(l:lnum)
            if l:line =~ '^\s*$' | continue | endif
            " Insert opening tag
            let l:line = substitute(l:line, '^\(\s\{' . l:min_indent . '\}\)', '\1' . l:open . ' ', '')
            " Append closing tag
            if l:close != ''
                let l:line = l:line . l:close
            endif
            call setline(l:lnum, l:line)
        endfor
    endif
endfunction

" Map Ctrl+/ to the function call for Normal and Visual modes
nnoremap <silent> <C-/> :call ToggleComment()<CR>
vnoremap <silent> <C-/> :call ToggleComment()<CR>gv

" === Custom Netrw Changes ===
function! NetrwPrepareMove()
    let l:curdir = b:netrw_curdir
    let l:filename = netrw#Call('NetrwGetWord')
    let l:sep = (has('win32') ? '\' : '/')
    let l:fullpath = l:curdir . (l:curdir =~ '[/\\]$' ? '' : l:sep) . l:filename
    let l:cmd = '!mv "' . l:fullpath . '" "' . l:fullpath . '"'

    " feedkeys triggers the CmdwinEnter autocmds above automatically via <C-f>
    call feedkeys('q:i' . l:cmd, 'n')
endfunction
augroup NetrwMoveOverride
    autocmd!
    autocmd FileType netrw nnoremap <buffer> R :call NetrwPrepareMove()<CR>
augroup END
" Add swap file patterns to the hiding list (comma-separated)
let g:netrw_list_hide = '.*\.swp$,.*\.swo$,.*\.swn$'
" Set the hiding mode to 'hide matching' by default (1 = hide, 0 = show all)
let g:netrw_hide = 1

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
    silent! packadd cfilter
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
\   'cpp': [],
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
