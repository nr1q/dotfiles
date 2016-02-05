" {{{ GENERAL

    syntax on
    colorscheme nrq_colors

    set nocompatible    " let's be iMproved
    set t_Co=256        " enable 256 colors
    set number          " show line numbers
    set nowrap          " wrapping disabled
    set timeoutlen=1000 " 1s for mappings
    set ttimeoutlen=10  " 10ms for codes
    set laststatus=2    " always show status line
    set showcmd         " show command in bottom
    set wildmenu        " better command completion
    set scrolloff=3     " lines visible above/below cursor
    set hidden          " don't delete history on buffer change
    set incsearch       " search while typing
    set ignorecase      " ignore upper case search strings
    set smartcase       " override ignore when upper case in search
    "set colorcolumn=80  " draw a line at the column limit

    " allow backspacing over autoindent, line breaks and start of insert action
    set backspace=indent,eol,start

    " completion options
    set completeopt=menu,menuone,longest,preview

    " c-indent options
    set cindent     " enable automatic indenting
    set cinoptions= " TODO find a nice value for this

    " indentation settings
    set expandtab     " use spaces instead of tabs
    set softtabstop=4 " number of spaces for each tab
    set shiftwidth=4  " <<, >> and cindent uses this value

    " traditional behaviour when moving cursor
    set whichwrap=b,s,h,l,<,>,[,]

    " list invisible chars
    set listchars=tab:▸\ ,space:\ ,extends:▸,precedes:◂,eol:¬

    " new windows at bottom
    set splitbelow

    " symmetric encryption
    set cryptmethod=blowfish2

" }}}

" {{{ PLUGINS AND SETTINGS

    " Tim Pope's
    execute pathogen#infect()

    " load filetype plugins/indent settings
    filetype plugin indent on

    " enabling Powerline fonts
    let g:airline_theme = "powerlineish"
    let g:airline_powerline_fonts = 1

    " turn on case sensitive feature
    let g:EasyMotion_smartcase = 1

    " prevent Emmet creating global mappings
    let g:user_emmet_install_global = 0

    " indentation guides
    let g:indent_guides_enable_on_vim_startup = 1
    let g:indent_guides_guide_size = 1
    let g:indent_guides_auto_colors = 0
    let g:indent_guides_start_level = 2


    " SuperCollider
    " -------------

    "let g:sclangKillOnExit = 1
    "let g:sclangTerm = "urxvt -e"
    "let g:sclangPipeApp = '/usr/bin/sclangpipe_app'
    "let g:sclangPipeApp     = "~/.vim/bundle/scvim/bin/start_pipe"
    "let g:sclangDispatcher  = "~/.vim/bundle/scvim/bin/sc_dispatcher"


    " javascript
    " ----------

    let javascript_enable_domhtmlcss    = 1
    let g:javascript_conceal_function   = "ƒ"
    let g:javascript_conceal_null       = "ø"
    let g:javascript_conceal_this       = "@"
    let g:javascript_conceal_return     = "⇚"
    let g:javascript_conceal_undefined  = "¿"
    let g:javascript_conceal_NaN        = "ℕ"
    let g:javascript_conceal_prototype  = "¶"
    let g:javascript_conceal_static     = "•"
    let g:javascript_conceal_super      = "Ω"


    " CtrlP
    " -----

    set wildignore+=*/tmp/*,*.so,*.swp,*.zip,*/vendor/*,*/\.git/*
    "let g:ctrlp_custom_ignore = '\v[\/]\.(git|hg|svn)$'
    let g:ctrlp_cache_dir = '~/.cache/ctrlp'
    "let g:ctrlp_user_command = ['.git/', 'git --git-dir=%s/.git ls-files -oc --exclude-standard']
    let g:ctrlp_user_command = {
        \ 'types': {
            \ 1: ['.git', 'git ls-files --cached --exclude-standard --others'],
        \ },
        \ 'fallback': 'find %s -type f -path "*/src/*"'
    \ }
        "\ 'fallback': 'find %s -type f ! -path "*/.git/*" ! -path "*/.hg/*" ! -path "*/.svn/*" | xargs file | grep "ASCII text" | awk -F: "{print $1}"'


    " YouCompleteMe
    " -------------

    let g:ycm_key_list_previous_completion = ['<Up>']
    let g:ycm_key_list_select_completion   = ['<Down>']
    let g:ycm_collect_identifiers_from_tags_files = 1

    " don't disable syntastic c-family checkers
    "let g:ycm_show_diagnostics_ui = 0


    " Ultisnips
    " ---------

    let g:UltiSnipsSnippetsDir   = "~/.vim/snippets/"


    " Syntastic
    " ---------

    let g:airline#extensions#tabline#enabled = 1

    "let g:syntastic_cpp_no_include_search = 1
    "let g:syntastic_cpp_auto_refresh_includes = 1
    "let g:syntastic_cpp_remove_include_errors = 1

    " Fish shell doesn't support the standard
    " UNIX syntax for file redirections
    let g:syntastic_shell = "/bin/bash"

    " disable styling messages
    let g:syntastic_quiet_messages = {
        \ 'type': 'style' }


    " TagList Options
    " ---------------

    " set the names of flags
    let tlist_php_settings = 'd:constant;php;c:class;f:function'
    " close all folds except for current file
    let Tlist_File_Fold_Auto_Close = 1
    " make tlist pane active when opened
    let Tlist_GainFocus_On_ToggleOpen = 1
    " width of window
    let Tlist_WinWidth = 40
    " close tlist when a selection is made
    let Tlist_Close_On_Select = 1

" }}}

" {{{ AUTOCOMMANDS

    " remove trailing spaces on save
    autocmd BufWritePre * :%s/\s\+$//e

    " PHP autocompletion
    autocmd FileType php set omnifunc=phpcomplete#CompletePHP

    " Emmet
    autocmd FileType php,html,css EmmetInstall

    " C-Family
    "autocmd FileType c,cc,cpp,h,hpp set tags +=~/.vim/tags/cpp

    " compile and run
    autocmd FileType c,cc,cpp,h,hpp nnoremap <F4> :call SwitchHeader()<CR>
    autocmd FileType c nnoremap <F5> :w <bar> exec '!gcc '.shellescape('%').' -o '.shellescape('%:r').'; and '.shellescape('%:p:r')<CR>
    autocmd FileType cpp nnoremap <F5> :w <bar> exec '!g++ -std=c++11 '.shellescape('%').' -o '.shellescape('%:r').'; and '.shellescape('%:p:r')<CR>
    autocmd FileType python nnoremap <buffer> <F5> :w <bar> exec '!python '.shellescape('%')<CR>
    autocmd FileType markdown nnoremap <F5> :w <bar> !markdown % <bar> lynx -stdin<CR>

    " openFrameworks
    autocmd BufNewFile,BufRead,BufEnter */of*64/* let g:syntastic_cpp_include_dirs = ['./', '../../../libs/openFrameworks']
    autocmd BufNewFile,BufRead,BufEnter */of*64/* nnoremap <F5> :w <bar> make -C .. -j 4; and make -C .. run<CR>

    " close automatically the Omni-completion tip window after a selection is made
    "autocmd CursorMovedI * if pumvisible() == 0|pclose|endif
    "autocmd InsertLeave * if pumvisible() == 0|pclose|endif

    " color the indentation guides
    autocmd VimEnter,ColorScheme * :highlight IndentGuidesOdd ctermbg=235
    autocmd VimEnter,ColorScheme * :highlight IndentGuidesEven ctermbg=233

" }}}

" {{{ MAPPINGS

    " making Y act like D or C
    map Y y$

    " delete buffer without losing split
    " http://stackoverflow.com/a/4468491
    nmap <silent> <leader>d :bp\|bd #<CR>

    " switching to another buffer
    set switchbuf=usetab
    nnoremap [5^ :bprevious<CR>
    nnoremap [6^ :bnext<CR>

    " togglers
    nnoremap <F8>  :set list!<CR>
    nnoremap <F9>  :set paste!<CR>
    nnoremap <F10> :set wrap!<CR>
    nnoremap <F11> :NERDTreeToggle<CR>
    nnoremap <F12> :TagbarToggle<CR>

    " quick save
    noremap  <silent> <C-S> :update<CR>
    vnoremap <silent> <C-S> <C-c>:update<CR>gv
    vnoremap <silent> <C-S> <esc>:w<CR>gv
    inoremap <silent> <C-S> <C-o>:update<CR>

    " go to buffer by number
    nnoremap gb :ls<CR>:b<space>

    " select last changed/pasted text
    "nnoremap gp `[v`]`]`
    nnoremap gp `[v`]`]

    " move lines up and down using Alt
    nnoremap j :m .+1<CR>==
    nnoremap k :m .-2<CR>==
    inoremap j <Esc>:m .+1<CR>==gi
    inoremap k <Esc>:m .-2<CR>==gi
    vnoremap j :m '>+1<CR>gv=gv
    vnoremap k :m '<-2<CR>gv=gv

    " use page up/down keys as ctrl+(u|d)
    nnoremap <PageUp>   <C-u>
    nnoremap <PageDown> <C-d>

    " allow saving of files as sudo when I forgot to start vim using sudo.
    " note: '> /dev/null' throws away the stdout since we do not need it.
    cmap w!! w !sudo tee > /dev/null %
    " map the accidental :W -> :w
    cmap :W :w

    " start interactive EasyAlign in visual mode (e.g. vip<Enter>)
    vmap <Enter> <Plug>(EasyAlign)

    " start interactive EasyAlign for a motion/text object (e.g. gaip)
    nmap ga <Plug>(EasyAlign)

    " open omni completion menu closing previous if open
    " and opening new menu without changing the text
    inoremap <expr> <C-Space> (pumvisible() ? (col('.') > 1 ? '<Esc>i<Right>' : '<Esc>i') : '') .
                            \ '<C-x><C-o><C-r>=pumvisible() ? "\<lt>C-n>\<lt>C-p>\<lt>Down>" : ""<CR>'

    " open user completion menu closing previous if open
    " and opening new menu without changing the text
    inoremap <expr> <S-Space> (pumvisible() ? (col('.') > 1 ? '<Esc>i<Right>' : '<Esc>i') : '') .
                            \ '<C-x><C-u><C-r>=pumvisible() ? "\<lt>C-n>\<lt>C-p>\<lt>Down>" : ""<CR>'


    " Easy Motion
    " -----------

    "let g:EasyMotion_do_mapping = 0 " Disable default m<A-k>appings
    map ,m <Plug>(easymotion-prefix)

    " Bi-directional find motion
    " Jump to anywhere you want with minimal keystrokes, with just one key
    " binding.
    " `s{char}{label}`
    nmap <Leader>s <Plug>(easymotion-s)
    " or
    " `s{char}{char}{label}`
    " Need one more keystroke, but on average, it may be more comfortable.
    nmap <Leader>s <Plug>(easymotion-s2)

    " JK motions: Line motions
    map <Leader>j <Plug>(easymotion-j)
    map <Leader>k <Plug>(easymotion-k)

    " show highlighting groups for current word
    nmap <C-S-G> :call <SID>SynStack()<CR>

    command! -bar Ranger call RangerChooser()
    nnoremap <leader>r :<C-U>Ranger<CR>

" }}}

" {{{ FUNCTIONS

    function! <SID>SynStack()
        if !exists("*synstack")
            return
        endif
        echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
    endfunc


    " Ranger as file chooser
    " ----------------------

    " It can be started using the command ":Ranger"
    " or the keybinding "<leader>r". Once you select one or more
    " files, press enter and ranger will quit again and vim will
    " open the selected files.

    function! RangerChooser()
        let temp = tempname()
        " The option "--choosefiles" was added in ranger 1.5.1. Use the next line
        " with ranger 1.4.2 through 1.5.0 instead.
        "exec 'silent !ranger --choosefile=' . shellescape(temp)
        exec 'silent !ranger --choosefiles=' . shellescape(temp)
        if !filereadable(temp)
            redraw!
            " Nothing to read.
            return
        endif
        let names = readfile(temp)
        if empty(names)
            redraw!
            " Nothing to open.
            return
        endif
        " Edit the first item.
        exec 'edit ' . fnameescape(names[0])
        " Add any remaning items to the arg list/buffer list.
        for name in names[1:]
            exec 'argadd ' . fnameescape(name)
        endfor
        redraw!
    endfunction

    " Switch header for .c, .cc, .cpp, .h and .hpp files
    " --------------------------------------------------

    function! SwitchHeader()
        let filenoext = expand('%:p:r')
        let fileext = expand('%:e')
        if l:fileext == 'c' || l:fileext == 'cc' || l:fileext == 'cpp'
            if filereadable(l:filenoext . ".h")
                exec 'edit ' .  l:filenoext . '.h'
            elseif filereadable(filenoext . ".hpp")
                exec 'edit ' .  l:filenoext . '.hpp'
            endif
        else
            if filereadable(l:filenoext . ".c")
                exec 'edit ' .  l:filenoext . '.c'
            elseif filereadable(filenoext . ".cc")
                exec 'edit ' .  l:filenoext . '.cc'
            elseif filereadable(l:filenoext . ".cpp")
                exec 'edit ' .  l:filenoext . '.cpp'
            endif
        endif
    endfunction

" }}}

" vim: foldmethod=marker :foldlevel=0
