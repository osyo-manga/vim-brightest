scriptencoding utf-8
if exists('g:loaded_brightest')
  finish
endif
let g:loaded_brightest = 1

let s:save_cpo = &cpo
set cpo&vim

let g:brightest_pattern = get(g:, "brightest_pattern",  '')
" let g:brightest_pattern = get(g:, "brightest_pattern",  '\k\+')
" let g:brightest_highlight_group = get(g:, "brightest_highlight_group", "WarningMsg")
" let g:brightest_highlight_group_in_cursor = get(g:, "brightest_highlight_group_in_cursor", "")
" let g:brightest_highlight_group_in_cursorline = get(g:, "brightest_highlight_group_in_cursorline", "")

let g:brightest_enable = get(g:, "brightest_enable", 1)


let s:highlight_default = {
\	"group" : "WarningMsg",
\	"priority" : -1,
\	"format" : '\<%s\>',
\}
let g:brightest_highlight = get(g:, "brightest_highlight", {})
function! s:highlight()
	return get(b:, "brightest_highlight", extend(s:highlight_default, g:brightest_highlight))
endfunction


let s:highlight_in_cursorline_default = {
\	"group" : "",
\	"priority" : -1,
\	"format" : '\<%s\>',
\}
let g:brightest_highlight_in_cursorline = get(g:, "brightest_highlight_in_cursorline", {})
function! s:highlight_in_cursorline()
	return get(b:, "brightest_highlight_in_cursorline", extend(s:highlight_in_cursorline_default, g:brightest_highlight_in_cursorline))
endfunction


function! s:init_hl()
	highlight BrightestDefaultCursorWord gui=underline guifg=NONE
	highlight BrightestUnderline term=underline cterm=underline gui=underline
endfunction

function! s:hl()
	call brightest#highlight(
\		get(b:, "brightest_pattern", g:brightest_pattern),
\		s:highlight(),
\		s:highlight_in_cursorline(),
\	)
endfunction

command! -bar BrightestEnable  let g:brightest_enable = 1 | call s:hl()
command! -bar BrightestDisable let g:brightest_enable = 0 | call brightest#hl_clear()


augroup brightest
	autocmd!
	autocmd CursorMoved * call s:hl()
	autocmd BufLeave,WinLeave,InsertEnter * call brightest#hl_clear()
	autocmd ColorScheme * call s:init_hl()
augroup END



let &cpo = s:save_cpo
unlet s:save_cpo
