scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim


function! s:_vital_loaded(V)
	let s:V = a:V
	let s:Buffer = s:V.import("Coaster.Buffer")
endfunction


function! s:_vital_depends()
	return [
\	]
endfunction


function! s:region(pattern, ...)
	let flag_first = get(a:, 1, "")
	let flag_last  = get(a:, 2, "")
	return [searchpos(a:pattern, flag_first), searchpos(a:pattern, flag_last)]
endfunction


function! s:region_pair(fist, last, ...)
	" todo
endfunction


function! s:pattern_in_range(wise, first, last, pattern)
	if a:first == a:last
		return printf('\%%%dl\%%%dc', a:first[0], a:first[1])
	elseif a:first[0] == a:last[0]
		return printf('\%%%dl\%%>%dc%s\%%<%dc', a:first[0], a:first[1]-1, a:pattern, a:last[1]+1)
	elseif a:last[0] - a:first[0] == 1
		return  printf('\%%%dl%s\%%>%dc', a:first[0], a:pattern, a:first[1]-1)
\		. "\\|" . printf('\%%%dl%s\%%<%dc', a:last[0], a:pattern, a:last[1]+1)
	else
		return  printf('\%%%dl%s\%%>%dc', a:first[0], a:pattern, a:first[1]-1)
\		. "\\|" . printf('\%%>%dl%s\%%<%dl', a:first[0], a:pattern, a:last[0])
\		. "\\|" . printf('\%%%dl%s\%%<%dc', a:last[0], a:pattern, a:last[1]+1)
	endif
endfunction


function! s:pattern_by_range(wise, first, last)
	return s:pattern_in_range(a:wise, a:first, a:last, '.\{-}')
endfunction


function! s:text_by_pattern(pattern, ...)
	let flag = get(a:, 1, "")
	let [first, last] = s:region(a:pattern, "c" . flag, "ce" . flag)
	if first == [0, 0] || last == [0, 0]
	endif
	let result = s:Buffer.get_text_from_region([0] + first + [0], [0] + last + [0], "v")
	return result
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
