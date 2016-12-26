scriptencoding utf-8
if exists('g:loaded_brightest') || v:version < 702
  finish
endif
let g:loaded_brightest = 1

if v:version < 702
	echohl ErrorMsg | echom "brightest.vim : Requirement Vim version 7.2 or above." | echohl NONE
	finish
endif

let s:save_cpo = &cpo
set cpo&vim


let g:brightest_enable = get(g:, "brightest_enable", 1)


function! s:init_hl()
	highlight BrightestDefaultCursorWord gui=underline guifg=NONE
	highlight BrightestUnderline term=underline cterm=underline gui=underline
	highlight BrightestUndercurl term=undercurl cterm=undercurl gui=undercurl
	highlight BrightestReverse term=reverse cterm=reverse gui=reverse
	highlight BrightestCursorLineBg NONE
	highlight BrightestNONE NONE
endfunction
call s:init_hl()


command! -bar BrightestHighlight call brightest#highlighting()
command! -bar BrightestClear     call brightest#hl_clear()
command! -bar BrightestEnable  let g:brightest_enable = 1 | BrightestHighlight
command! -bar BrightestDisable let g:brightest_enable = 0 | BrightestClear
command! -bar BrightestUnlock  let b:brightest_enable = 1 | BrightestHighlight
command! -bar BrightestLock    let b:brightest_enable = 0 | BrightestClear
command! -bar BrightestToggle  if g:brightest_enable | BrightestDisable | else | BrightestEnable | endif


augroup brightest
	autocmd!
	autocmd CursorMoved * call brightest#on_CursorMoved()
	autocmd WinEnter    * call brightest#on_CursorMoved()
	autocmd CursorHold  * call brightest#on_CursorHold()
	autocmd WinLeave    * call brightest#hl_clear()
" 	autocmd BufLeave,WinLeave * call brightest#hl_clear()
	autocmd ColorScheme * call s:init_hl()

	autocmd CursorMovedI *
\		if g:brightest#enable_insert_mode
\|			call brightest#on_CursorMoved()
\|		endif
	autocmd CursorHoldI *
\		if g:brightest#enable_insert_mode
\|			call brightest#on_CursorHold()
\|		endif
	autocmd InsertEnter *
\		if g:brightest#enable_insert_mode == 0
\|			call brightest#hl_clear()
\|		endif
augroup END



let &cpo = s:save_cpo
unlet s:save_cpo
