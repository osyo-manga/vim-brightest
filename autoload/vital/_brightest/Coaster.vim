scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim


function! s:_vital_depends()
	return [
\		"Coaster.Buffer",
\		"Coaster.Search",
\		"Coaster.Highlight"
\	]
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
