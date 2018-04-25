set runtimepath+=~/dotfiles/vim
" load plugins
set runtimepath+=~/dotfiles/vim/vim-go
set runtimepath+=~/dotfiles/vim/vim-ctrlp
set runtimepath+=~/dotfiles/vim/vim-nerdtree


" dont care about vi
set nocompatible

" fuzzy: recursive search
set path+=**

" auto complete for finding files
set wildmenu

" enable syntax and plugins
syntax enable
filetype plugin on

" tag support: run MakeTags in you cwd to create a list
" use ^] to jump
" use ^t to get back
" use g^] go get a list
command! MakeTags !ctags -R .

" autocomplete | docs at ins-completion
" - ^n autocomplete everything
" - ^x^n in this file
" - ^x^f filenames
" - ^x^] for tags
" - ^n and ^p to go back and forth

" basic sanity
let mapleader=","
set autoindent
set expandtab
set tabstop=4
set shiftwidth=2
set dir=/tmp/
set mouse=a
set incsearch
set hlsearch
set backspace=indent,eol,start
set splitbelow
set splitright
set relativenumber
set number
set laststatus=2
set cursorline
set list listchars=tab:\|_,trail:·

" experimental stuff

" //////////////

" clipboard
set clipboard=unnamedplus

" key mapping
map <tab> %
map <leader>k :NERDTreeToggle<CR>
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

" visual select line
nnoremap vv 0v$

" File and Window Management 
inoremap <leader>w <Esc>:w<CR>
nnoremap <leader>w :w<CR>
inoremap <leader>q <Esc>:q<CR>
nnoremap <leader>q :q<CR>

" Return to the same line you left off at
augroup line_return
au!
    au BufReadPost *
        \ if line("'\"") > 0 && line("'\"") <= line("$") |
        \   execute 'normal! g`"zvzz' |
        \ endif
augroup END

source ~/dotfiles/vim/nord.vim



