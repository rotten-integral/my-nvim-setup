" ---<<Custom Made init.vim mainly for latex typesetting and cpp>>--
" ---<<Lazy.nvim Installation/Bootstrap>>---
lua << EOF
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({"git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", lazypath})
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- Place your plugin definitions here...

{ 'folke/tokyonight.nvim', lazy = false, priority = 1000 },
{ 'lukas-reineke/indent-blankline.nvim', main = "ibl", opts = {} },
{ "sphamba/smear-cursor.nvim", opts = {} },
{ "frabjous/knap" },
})
EOF



" ---<<Sourcing the colorscheme.lua file>>---
lua require('config.colorscheme')
"---------------------------------------------------------------------------
if &diffopt !~# 'internal'
  set diffexpr=MyDiff()
endif
function MyDiff()
  let opt = '-a --binary '
  if &diffopt =~ 'icase' | let opt = opt . '-i ' | endif
  if &diffopt =~ 'iwhite' | let opt = opt . '-b ' | endif
  let arg1 = v:fname_in
  if arg1 =~ ' ' | let arg1 = '"' . arg1 . '"' | endif
  let arg1 = substitute(arg1, '!', '\!', 'g')
  let arg2 = v:fname_new
  if arg2 =~ ' ' | let arg2 = '"' . arg2 . '"' | endif
  let arg2 = substitute(arg2, '!', '\!', 'g')
  let arg3 = v:fname_out
  if arg3 =~ ' ' | let arg3 = '"' . arg3 . '"' | endif
  let arg3 = substitute(arg3, '!', '\!', 'g')
  if $VIMRUNTIME =~ ' '
    if &sh =~ '\<cmd'
      if empty(&shellxquote)
        let l:shxq_sav = ''
        set shellxquote&
      endif
      let cmd = '"' . $VIMRUNTIME . '\diff"'
    else
      let cmd = substitute($VIMRUNTIME, ' ', '" ', '') . '\diff"'
    endif
  else
    let cmd = $VIMRUNTIME . '\diff'
  endif
  let cmd = substitute(cmd, '!', '\!', 'g')
  silent execute '!' . cmd . ' ' . opt . arg1 . ' ' . arg2 . ' > ' . arg3
  if exists('l:shxq_sav')
    let &shellxquote=l:shxq_sav
  endif
endfunction

" --<<Nvim Global default settings>>--
set number
au GUIEnter * simalt ~x              " Start GVim maximized
set guifont=consolas:h18             " Consolas font with height 18
set spell spelllang=en_gb            " Spell check set to British English
set cursorline                       " Highlights the current line
set clipboard=unnamed
set tabstop=4                        " Number of spaces a <Tab> displays as
set shiftwidth=4                     " Number of spaces for auto-indent
set noexpandtab
syntax on
set termguicolors
set guioptions-=T
set smartindent

inoremap { {}<Left>
inoremap {<CR> {<CR>}<Esc>O
inoremap {{ {
inoremap {} {}

inoremap ( ()<Left>
inoremap (<CR> (<CR>)<Esc>O
inoremap (( (
inoremap () ()

inoremap [ []<Left>
inoremap [<CR> [<CR>]<Esc>O
inoremap [] [
inoremap [] []
"---------------------------------------------------------------------------


" ---<<LaTeX specific stuff>>---
" ---<<LaTeX Compile Function>>---
function! CompileAndOpenLatex()
    " 1. Check if pdflatex exists
    if !executable('pdflatex')
        echohl ErrorMsg
        echo "ERROR: pdflatex not found. Install MiKTeX or TeX Live."
        echohl None
        return
    endif
    
    echo "The Devil is Busy Compiling LaTeX wait..."
    
    " 2. Compile to PDF
    " Use shellescape() for robust handling of file paths with spaces on Windows
    let l:tex_file = shellescape(expand('%:p'))
    
    " The compilation command: runs pdflatex without stopping for errors.
    " Note: The ! executes the external command and prints its output to Vim's command area.
    execute '!pdflatex -interaction=nonstopmode ' . l:tex_file
    
    echohl WarningMsg
    echo "Compilation finished. Check Vim messages for output/errors."
    echohl None
endfunction

" ---<<F5 Mapping to compile latex>>---
augroup latex_compile
    autocmd!
    " Map F5 to save (:w) and call the compile function.
    autocmd FileType tex nnoremap <buffer> <F5> :w<CR>:call CompileAndOpenLatex()<CR>
augroup END

" Auto-insert LaTeX Preamble
augroup latex_preamble
    autocmd!
    autocmd BufNewFile *.tex 0r C:\Users\anude\preamble.tex
augroup END

augroup latex_mathmode_completion
    autocmd!
	autocmd FileType tex inoremap \[ \[\]<Left><left>
	autocmd FileType tex inoremap \[<CR> \[<CR>\]<Esc>O
	autocmd FileType tex inoremap \[\] \[
	autocmd FileType tex inoremap \[\] \[\]

	autocmd FileType tex inoremap $ $$<Left>
	autocmd FileType tex inoremap $<CR> $<CR>$<Esc>O
	autocmd FileType tex inoremap $$ $
	autocmd FileType tex inoremap $$ $$
augroup END

augroup latex_autotype
    autocmd!
    autocmd FileType tex inoremap Proof: \begin{myproof}<CR><CR>\end{myproof}<Esc>kA
    autocmd FileType tex inoremap Solution: \begin{solution}<CR><CR>\end{solution}<Esc>kA
	autocmd FileType tex inoremap Problem: \begin{problem}{}{\href{}{}}<CR><CR>\end{problem}<Esc>kA
    autocmd FileType tex inoremap Align: \begin{align*}<CR><CR>\end{align*}<Esc>kA
    autocmd FileType tex inoremap Numalign: \begin{align}<CR><CR>\end{align}<Esc>kA
	autocmd FileType tex inoremap Theorem: \begin{theorem}{}{}<CR><CR>\end{theorem}<Esc>kA
	autocmd FileType tex inoremap Notitthm: \begin{notithm}{}<CR><CR>\end{notitthm}<Esc>kA
	autocmd FileType tex inoremap Asy: \begin{asy}<CR>size(5cm);<CR>import geometry;<CR>\end{asy}<Esc>kA
	autocmd FileType tex inoremap Remark: \begin{remark}<CR><CR>\end{remark}<Esc>kA
	autocmd FileType tex inoremap Lemma: \begin{lemma}{}<CR><CR>\end{lemma}<Esc>kA
	autocmd FileType tex inoremap Proposition: \begin{proposition}{}<CR><CR>\end{proposition}<Esc>kA
	autocmd FileType tex inoremap Example: \begin{example}{}<CR><CR>\end{example}<Esc>kA
	autocmd FileType tex inoremap Claim: \begin{claim}<CR><CR>\end{claim}<Esc>kA
	autocmd FileType tex inoremap Numeqn: \begin{equation}<CR><CR>\end{equation}<Esc>kA
	autocmd FileType tex inoremap Eqn: \begin{equation*}<CR><CR>\end{equation*}<Esc>kA
	autocmd FileType tex inoremap Takeaway: \begin{takeaway}<CR><CR>\end{takeaway}<Esc>kA
	autocmd FileType tex inoremap Numclaim: \begin{numclaim}{}<CR><CR>\end{numclaim}<Esc>kA
	autocmd FileType tex inoremap Code: \begin{verbatim}<CR><CR>\end{verbatim}<Esc>kA
	autocmd FileType tex inoremap Tabular: \begin{tabular}{}<CR><CR>\end{tabular}<Esc>kA
	autocmd FileType tex inoremap Gather: \begin{gathered*}<CR><CR>\end{gathered*}<Esc>kA
	autocmd FileType tex inoremap Numgather: \begin{gathered}<CR><CR>\end{gathered}<Esc>kA
	autocmd FileType tex inoremap Center: \begin{center}<CR><CR>\end{center}<Esc>kA
	autocmd FileType tex inoremap <buffer> Qed: $\qedwhite$
	autocmd FileType tex inoremap Itemize: \begin{itemize}<CR>\item<CR>\end{itemize}<Esc>kA
	autocmd FileType tex inoremap Enumerate: \begin{enumerate}<CR>\item<CR>\end{enumerate}<Esc>kA
	autocmd FileType tex inoremap Mycases: \begin{mycases}<CR>\item<CR>\end{mycases}<Esc>kA
	autocmd FileType tex inoremap Cases: \begin{cases}<CR>\item<CR>\end{cases}<Esc>kA	
	autocmd FileType tex inoremap Figure: \begin{figure}[]<CR>\includegraphics[]{}<CR>\end{figure}<Esc>kA
augroup END


""""""""""""""""""
" KNAP functions "
""""""""""""""""""
" F5 processes the document once, and refreshes the view "
inoremap <silent> <F4> <C-o>:lua require("knap").process_once()<CR>
vnoremap <silent> <F4> <C-c>:lua require("knap").process_once()<CR>
nnoremap <silent> <F4> :lua require("knap").process_once()<CR>

" F6 closes the viewer application, and allows settings to be reset "
inoremap <silent> <F6> <C-o>:lua require("knap").close_viewer()<CR>
vnoremap <silent> <F6> <C-c>:lua require("knap").close_viewer()<CR>
nnoremap <silent> <F6> :lua require("knap").close_viewer()<CR>

" F7 toggles the auto-processing on and off "
inoremap <silent> <F7> <C-o>:lua require("knap").toggle_autopreviewing()<CR>
vnoremap <silent> <F7> <C-c>:lua require("knap").toggle_autopreviewing()<CR>
nnoremap <silent> <F7> :lua require("knap").toggle_autopreviewing()<CR>

" F8 invokes a SyncTeX forward search, or similar, where appropriate "
inoremap <silent> <F8> <C-o>:lua require("knap").forward_jump()<CR>
vnoremap <silent> <F8> <C-c>:lua require("knap").forward_jump()<CR>
nnoremap <silent> <F8> :lua require("knap").forward_jump()<CR>


" Vimscript configuration (in init.vim)
let g:vimtex_view_method = 'sioyek'

" This is CRITICAL. Adjust the path as necessary for your system.
" Example for Windows:
" let g:vimtex_view_sioyek_exe = 'C:/Program Files/Sioyek/sioyek.exe'
" Example for Linux/macOS (if it's in your PATH):
let g:vimtex_view_sioyek_exe = 'sioyek'
"---------------------------------------------------------------------------


" --<<c++ compilation commands>>--
autocmd filetype cpp nnoremap <F9> :w <bar> !g++ -std=c++14 % -o %:r -Wl,--stack,268435456<CR>
autocmd filetype cpp nnoremap <C-C> :s/^\(\s*\)/\1\/\/<CR> :s/^\(\s*\)\/\/\/\//\1<CR> $

"opens an external terminal
autocmd FileType cpp nnoremap <F10> :w \| :!g++ -std=c++17 -O2 -Wall % -o %:r && start cmd /k %:r.exe<CR>
autocmd FileType tex lcd %:p:h
"---------------------------------------------------------------------------
