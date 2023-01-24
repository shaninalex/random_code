set tabstop=4
set shiftwidth=4
set expandtab
set number

" PLUGINS
call plug#begin('~/.vim/plugged')
" Theme
Plug 'ayu-theme/ayu-vim'

" filesearch
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" Support golang 
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
Plug 'preservim/nerdtree'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'habamax/vim-polar'
call plug#end()

" Some part ( the parts that I understand ) I get from here: https://linuxize.com/post/how-to-show-line-numbers-in-vim/
set autowrite

" Go syntax highlighting
let g:go_highlight_fields = 1
let g:go_highlight_functions = 1
let g:go_highlight_function_calls = 1
let g:go_highlight_extra_types = 1
let g:go_highlight_operators = 1

let g:go_fmt_autosave = 1
let g:go_fmt_command = "goimports"


" Colorscheme
set termguicolors     " enable true colors support
let ayucolor="dark"   " for dark version of theme
colorscheme ayu


filetype plugin indent on

