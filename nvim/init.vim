" Vim with all enhancements
" --- Lazy.nvim Installation/Bootstrap ---

lua << EOF
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({"git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", lazypath})
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- Place your plugin definitions here...

{ 'folke/tokyonight.nvim', lazy = false, priority = 1000 },
})
EOF




" -----------------------------------------------------------

" --- Your existing Vimscript starts here ---
" ... your original init.vim code ...

" --- Sourcing the colorscheme.lua file (as previously discussed) ---
lua require('config.colorscheme')



" Use the internal diff if available.
" Otherwise use the special 'diffexpr' for Windows.
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


" ============================
" Basic GVim settings for LaTeX-Added later by Anudeep
" ============================

" ============================
" Basic GVim settings for LaTeX
" ============================

" Always show line numbers
set number

" Start GVim maximized
au GUIEnter * simalt ~x

" Font settings (change size if needed)
set guifont=consolas:h18
set spell spelllang=en_gb




" Auto-compile LaTeX to PDF on save
"augroup latex_auto_compile
"    autocmd!
"    autocmd BufWritePost *.tex silent! execute '!cmd /k pdflatex -interaction=nonstopmode "' . expand('%:p') . '"'
"augroup END


" Highlight current line
set cursorline




" ============================" SIMPLIFIED LaTeX Compile Function" ============================
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

" ============================" F5 Mapping to compile latex" ============================
augroup latex_compile
    autocmd!
    " Map F5 to save (:w) and call the compile function.
    autocmd FileType tex nnoremap <buffer> <F5> :w<CR>:call CompileAndOpenLatex()<CR>
augroup END


" ============================
" Auto-insert LaTeX Preamble
" ============================
augroup latex_preamble
    autocmd!
    autocmd BufNewFile *.tex 0r C:\Users\anude\preamble.tex
augroup END


"sets system clipboard
set clipboard=unnamed



set tabstop=4       " Number of spaces a <Tab> displays as
set shiftwidth=4    " Number of spaces for auto-indent
set noexpandtab

syntax on
set termguicolors
set guioptions-=T

"colorscheme retrobox

" c++ compilation commands
inoremap { {}<Left>
inoremap {<CR> {<CR>}<Esc>O
inoremap {{ {
inoremap {} {}

inoremap $ $$<Left>
inoremap $<CR> $<CR>$<Esc>O
inoremap $$ $
inoremap $$ $$
autocmd filetype cpp nnoremap <F9> :w <bar> !g++ -std=c++14 % -o %:r -Wl,--stack,268435456<CR>
"autocmd filetype cpp nnoremap <F10> :w <bar> !g++ -std=c++17 -O2 -Wall % -o %:r && %:r.exe <CR>
autocmd filetype cpp nnoremap <C-C> :s/^\(\s*\)/\1\/\/<CR> :s/^\(\s*\)\/\/\/\//\1<CR> $

"Opens the terminal in nvim itself
"autocmd FileType cpp nnoremap <F10> :w \| :!g++ -std=c++17 -O2 -Wall % -o %:r <CR> \| :terminal %:r.exe<CR>

"opens an external terminal
autocmd FileType cpp nnoremap <F10> :w \| :!g++ -std=c++17 -O2 -Wall % -o %:r && start cmd /k %:r.exe<CR>
" init.vim

" --- Ensure Neovim's Working Directory is set to the file's directory ---

" This autocommand runs every time you enter a buffer with the 'tex' filetype.
" 'lcd %:p:h' command:
"   l (local) cd: changes the current directory only for the current window.
"   %:p:h: expands to the full path (:p) of the current file, up to the directory name (:h = head).
autocmd FileType tex lcd %:p:h

" Optional : You can do this globally (for all files), but local (lcd) is safer
" autocmd BufEnter * lcd %:p:h


"Autotype in .tex files
augroup latex_proof_autotype
    autocmd!
    autocmd FileType tex inoremap Proof: <CR>\begin{myproof}<CR><CR>\end{myproof}<Esc>kA
augroup END



augroup latex_solution_autotype
    autocmd!
    autocmd FileType tex inoremap Solution: <CR>\begin{solution}<CR><CR>\end{solution}<Esc>kA
augroup END


augroup latex_problem_autotype
    autocmd!
	autocmd FileType tex inoremap Problem: <CR>\begin{problem}{}{}<CR><CR>\end{problem}<Esc>kA
augroup END


augroup latex_align_unnumbered_autotype
    autocmd!
    autocmd FileType tex inoremap Align: <CR>\begin{align*}<CR><CR>\end{align*}<Esc>kA
augroup END

augroup latex_align_autotype
    autocmd!
    autocmd FileType tex inoremap Numalign: <CR>\begin{align}<CR><CR>\end{align}<Esc>kA
augroup END


augroup latex_theorem_autotype
    autocmd!
	autocmd FileType tex inoremap Theorem: <CR>\begin{theorem}{}{}<CR><CR>\end{theorem}<Esc>kA
augroup END


augroup latex_theorem_notitle_autotype
    autocmd!
	autocmd FileType tex inoremap Notitthm: <CR>\begin{notithm}{}<CR><CR>\end{notitthm}<Esc>kA
augroup END


augroup latex_asy_autotype
    autocmd!
	autocmd FileType tex inoremap Asy: <CR>\begin{asy}<CR><CR>\end{asy}<Esc>kA
augroup END



augroup latex_remark_autotype
    autocmd!
	autocmd FileType tex inoremap Remark: <CR>\begin{remark}<CR><CR>\end{remark}<Esc>kA
augroup END



augroup latex_lemma_autotype
    autocmd!
	autocmd FileType tex inoremap Lemma: <CR>\begin{lemma}{}<CR><CR>\end{lemma}<Esc>kA
augroup END



augroup latex_proposition_autotype
    autocmd!
	autocmd FileType tex inoremap Proposition: <CR>\begin{proposition}{}<CR><CR>\end{proposition}<Esc>kA
augroup END


augroup latex_example_autotype
    autocmd!
	autocmd FileType tex inoremap Example: <CR>\begin{example}{}<CR><CR>\end{example}<Esc>kA
augroup END


augroup latex_claim_autotype
    autocmd!
	autocmd FileType tex inoremap Claim: <CR>\begin{claim}<CR><CR>\end{claim}<Esc>kA
augroup END



augroup latex_equation_numbered_autotype
    autocmd!
	autocmd FileType tex inoremap Numequation: <CR>\begin{equation}<CR><CR>\end{equation}<Esc>kA
augroup END




augroup latex_equation_autotype
    autocmd!
	autocmd FileType tex inoremap Equation: <CR>\begin{equation*}<CR><CR>\end{equation*}<Esc>kA
augroup END


augroup latex_takeaway_autotype
    autocmd!
	autocmd FileType tex inoremap Takeaway: <CR>\begin{takeaway}<CR><CR>\end{takeaway}<Esc>kA
augroup END


augroup latex_claim_numbered_autotype
    autocmd!
	autocmd FileType tex inoremap Numclaim: <CR>\begin{numclaim}{}<CR><CR>\end{numclaim}<Esc>kA
augroup END


augroup latex_verbatim_autotype
    autocmd!
	autocmd FileType tex inoremap Code: <CR>\begin{verbatim}<CR><CR>\end{verbatim}<Esc>kA
augroup END


augroup latex_tabular_autotype
    autocmd!
	autocmd FileType tex inoremap Tabular: <CR>\begin{tabular}{}<CR><CR>\end{tabular}<Esc>kA
augroup END


augroup latex_gathered_autotype
    autocmd!
	autocmd FileType tex inoremap Gathered: <CR>\begin{gathered*}<CR><CR>\end{gathered*}<Esc>kA
augroup END


augroup latex_gathered_numbered_autotype
    autocmd!
	autocmd FileType tex inoremap Numgathered: <CR>\begin{gathered}<CR><CR>\end{gathered}<Esc>kA
augroup END



augroup latex_center_autotype
    autocmd!
	autocmd FileType tex inoremap Center: <CR>\begin{center}<CR><CR>\end{center}<Esc>kA
augroup END


augroup latex_qed_autotype
    autocmd!
	autocmd FileType tex inoremap <buffer> Qed: $\qedwhite$
augroup END
