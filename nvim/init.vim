" ---<<Custom Made init.vim (of course with the help of gemini and chatgpt) mainly for typesetting tex files and c++ - rotten integral>>--
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
})
EOF

" ---<<intendation-lines setup>>---
lua << EOF
require("ibl").setup {
    indent = { char = "│" },       -- You can use '┊', '¦', or '▏'
    scope = { enabled = true },
}
EOF

" ---<<Sourcing the colorscheme.lua file>>---
lua require('config.colorscheme')
"---------------------------------------------------------------------------


" ---<<My existing Vimscript aka _vimrc>>---
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
	autocmd FileType tex inoremap \[ \[\]<Left>
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
    autocmd FileType tex inoremap proof: \begin{myproof}<CR><CR>\end{myproof}<Esc>kA
    autocmd FileType tex inoremap solution: \begin{solution}<CR><CR>\end{solution}<Esc>kA
	autocmd FileType tex inoremap problem: \begin{problem}{}{\href{}{}}<CR><CR>\end{problem}<Esc>kA
    autocmd FileType tex inoremap align: \begin{align*}<CR><CR>\end{align*}<Esc>kA
    autocmd FileType tex inoremap numalign: \begin{align}<CR><CR>\end{align}<Esc>kA
	autocmd FileType tex inoremap theorem: \begin{theorem}{}{}<CR><CR>\end{theorem}<Esc>kA
	autocmd FileType tex inoremap notitthm: \begin{notithm}{}<CR><CR>\end{notitthm}<Esc>kA
	autocmd FileType tex inoremap asy: \begin{asy}<CR>size(5cm);<CR>import geometry;<CR>\end{asy}<Esc>kA
	autocmd FileType tex inoremap remark: \begin{remark}<CR><CR>\end{remark}<Esc>kA
	autocmd FileType tex inoremap lemma: \begin{lemma}{}<CR><CR>\end{lemma}<Esc>kA
	autocmd FileType tex inoremap proposition: \begin{proposition}{}<CR><CR>\end{proposition}<Esc>kA
	autocmd FileType tex inoremap example: \begin{example}{}<CR><CR>\end{example}<Esc>kA
	autocmd FileType tex inoremap claim: \begin{claim}<CR><CR>\end{claim}<Esc>kA
	autocmd FileType tex inoremap numequation: \begin{equation}<CR><CR>\end{equation}<Esc>kA
	autocmd FileType tex inoremap equation: \begin{equation*}<CR><CR>\end{equation*}<Esc>kA
	autocmd FileType tex inoremap takeaway: \begin{takeaway}<CR><CR>\end{takeaway}<Esc>kA
	autocmd FileType tex inoremap numclaim: \begin{numclaim}{}<CR><CR>\end{numclaim}<Esc>kA
	autocmd FileType tex inoremap code: \begin{verbatim}<CR><CR>\end{verbatim}<Esc>kA
	autocmd FileType tex inoremap tabular: \begin{tabular}{}<CR><CR>\end{tabular}<Esc>kA
	autocmd FileType tex inoremap gathered: \begin{gathered*}<CR><CR>\end{gathered*}<Esc>kA
	autocmd FileType tex inoremap numgathered: \begin{gathered}<CR><CR>\end{gathered}<Esc>kA
	autocmd FileType tex inoremap center: \begin{center}<CR><CR>\end{center}<Esc>kA
	autocmd FileType tex inoremap <buffer> qed: $\qedwhite$
	autocmd FileType tex inoremap itemize: \begin{itemize}<CR><CR>\end{itemize}<Esc>kA
	autocmd FileType tex inoremap enumerate: \begin{enumerate}<CR><CR>\end{enumerate}<Esc>kA
augroup END
"---------------------------------------------------------------------------


" --<<c++ compilation commands>>--
autocmd filetype cpp nnoremap <F9> :w <bar> !g++ -std=c++14 % -o %:r -Wl,--stack,268435456<CR>
autocmd filetype cpp nnoremap <C-C> :s/^\(\s*\)/\1\/\/<CR> :s/^\(\s*\)\/\/\/\//\1<CR> $

"opens an external terminal
autocmd FileType cpp nnoremap <F10> :w \| :!g++ -std=c++17 -O2 -Wall % -o %:r && start cmd /k %:r.exe<CR>
autocmd FileType tex lcd %:p:h
"---------------------------------------------------------------------------
