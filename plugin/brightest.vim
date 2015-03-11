scriptencoding utf-8
if exists('g:loaded_brightest')
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
endfunction
call s:init_hl()


command! -bar BrightestHighlight call brightest#highlighting()
command! -bar BrightestClear     call brightest#hl_clear()
command! -bar BrightestEnable  let g:brightest_enable = 1 | BrightestHighlight
command! -bar BrightestDisable let g:brightest_enable = 0 | BrightestClear
command! -bar BrightestUnlock  let b:brightest_enable = 1 | BrightestHighlight
command! -bar BrightestLock    let b:brightest_enable = 0 | BrightestClear
command! -bar BrightestToggle  if g:brightest_enable | BrightestDisable | else | BrightestEnable | endif


function! s:highlight()
	if g:brightest_enable && get(b:, "brightest_enable", 1)
		call brightest#highlighting()
	endif
endfunction

augroup brightest
	autocmd!
" 	autocmd CursorMoved * call s:highlight()
	autocmd CursorMoved * call brightest#on_CursorMoved()
	autocmd CursorHold  * call brightest#on_CursorHold()
	autocmd BufLeave,WinLeave,InsertEnter * call brightest#hl_clear()
	autocmd ColorScheme * call s:init_hl()
augroup END



let &cpo = s:save_cpo
unlet s:save_cpo
