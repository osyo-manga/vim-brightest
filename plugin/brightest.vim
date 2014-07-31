scriptencoding utf-8
if exists('g:loaded_brightest')
  finish
endif
let g:loaded_brightest = 1

let s:save_cpo = &cpo
set cpo&vim


let g:brightest_enable = get(g:, "brightest_enable", 1)


function! s:init_hl()
	highlight BrightestDefaultCursorWord gui=underline guifg=NONE
	highlight BrightestUnderline term=underline cterm=underline gui=underline
	highlight BrightestCursorLine NONE
endfunction
call s:init_hl()


command! -bar BrightestEnable  let g:brightest_enable = 1 | call brightest#highlight()
command! -bar BrightestDisable let g:brightest_enable = 0 | call brightest#hl_clear()

augroup brightest
	autocmd!
	autocmd CursorMoved * call brightest#highlighting()
	autocmd BufLeave,WinLeave,InsertEnter * call brightest#hl_clear()
	autocmd ColorScheme * call s:init_hl()
augroup END



let &cpo = s:save_cpo
unlet s:save_cpo
