:colorscheme elflord

set ls=2     " always show status line
set nobackup " no backup files

" size of a hard tabstop
set tabstop=4

" size of an "indent"
set shiftwidth=4

" a combination of spaces and tabs are used to simulate tab stops at a width
" other than the (hard)tabstop
set softtabstop=4

" make "tab" insert indents instead of tabs at the beginning of a line
set smarttab

" always uses spaces instead of tab characters
set expandtab

set nocompatible
syntax enable
set encoding=utf-8
set showcmd

set backspace=indent,eol,start
set hlsearch                    " highlight matches
set incsearch                   " incremental searching
set ignorecase                  " searches are case insensitive...
set smartcase                   " ... unless they contain at least one capital letter

set visualbell

map <F5> :w<CR>:!phpunit  --colors --strict --verbose %<CR>
map <F2> :wa<CR>
imap jj <Esc>
"imap ii <Esc>