scriptencoding utf-8
if exists('g:loaded_brightest')
  finish
endif
let g:loaded_brightest = 1

let s:save_cpo = &cpo
set cpo&vim


let g:brightest_enable = get(g:, "brightest_enable", 1)
let g:brightest_on_cursor_hold = get(g:, "brightest_on_cursor_hold", 0)


function! s:init_hl()
	highlight BrightestDefaultCursorWord gui=underline guifg=NONE
	highlight BrightestUnderline term=underline cterm=underline gui=underline
	highlight BrightestUndercurl term=undercurl cterm=undercurl gui=undercurl
	highlight BrightestCursorLineBg NONE
endfunction
call s:init_hl()


command! -bar BrightestHighlight call brightest#highlighting()
command! -bar BrightestClear     call brightest#hl_clear()
command! -bar BrightestEnable  let g:brightest_enable = 1 | BrightestHighlight
command! -bar BrightestDisable let g:brightest_enable = 0 | BrightestClear



augroup brightest
	autocmd!
	execute 'autocmd'
\		(g:brightest_on_cursor_hold ? 'CursorHold' : 'CursorMoved')
\		'* call brightest#highlighting()'
	autocmd BufLeave,WinLeave,InsertEnter * call brightest#hl_clear()
	autocmd ColorScheme * call s:init_hl()
augroup END



let &cpo = s:save_cpo
unlet s:save_cpo
