scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim

function! s:_vital_loaded(V)
	let s:V = a:V
	let s:Search = a:V.import("Coaster.Search")
endfunction


function! s:_vital_depends()
	return [
\		"Coaster.Search"
\	]
endfunction


" a <= b
function! s:pos_less_equal(a, b)
	return a:a[0] == a:b[0] ? a:a[1] <= a:b[1] : a:a[0] <= a:b[0]
endfunction


function! s:as_wise_key(name)
	return a:name ==# "char"  ? "v"
\		 : a:name ==# "line"  ? "V"
\		 : a:name ==# "block" ? "\<C-v>"
\		 : a:name
endfunction


function! s:get_text_from_latest_yank(...)
	if mode() != "n"
		return
	endif

	let wise = get(a:, 1, "v")
	let register = v:register == "" ? '"' : v:register

	let old_selection = &selection
	let &selection = 'inclusive'
	let old_pos = getpos(".")
	let old_reg = getreg(register)
	try
		execute printf('silent normal! `[%s`]y', wise)
		return getreg(register)
	finally
		let &selection = old_selection
		call setreg(register, old_reg)
		call cursor(old_pos[1], old_pos[2])
	endtry
endfunction


function! s:get_line_from_pos(pos)
	return a:pos[0] == 0 ? getline(a:pos[1]) : getbufline(a:pos[0], a:pos[1])
endfunction


function! s:get_line_from_region(first, last)
	if type(a:first) == type(0)
		return s:get_line_from_region([0, a:first, 0, 0], a:last)
	elseif type(a:last) == type(0)
		return s:get_line_from_region(a:first, [0, a:last, 0, 0])
	endif
	if a:first[0] != 0 && a:first[0] == a:last[0]
		return join(getbufline(a:first[0], a:first[1], a:last[1]), "\n")
	endif
	return join(getline(a:first[1], a:last[1]), "\n")
endfunction


function! s:yank(wise, first, last)
	let old_view = winsaveview()
	let old_selection = &selection
	let &selection = 'inclusive'
 	let old_first = getpos("'[")
 	let old_last  = getpos("']")
	let old_pos = getpos(".")
	try
		call setpos("'[", a:first)
		call setpos("']", a:last)
		execute "normal! `[" . a:wise . "`]y"
	finally
		call setpos("'[", old_first)
		call setpos("']", old_last)
		let &selection = old_selection
		call winrestview(old_view)
		call setpos(".", old_pos)
	endtry
endfunction


function! s:paste(wise, first, last, register)
	let old_view = winsaveview()
	let old_selection = &selection
	let &selection = 'inclusive'
 	let old_first = getpos("'[")
 	let old_last  = getpos("']")
	let old_pos = getpos(".")
	try
		call setpos("'[", a:first)
		call setpos("']", a:last)
		execute printf('normal! `[%s`]"%sp', a:wise, a:register)
	finally
		call setpos("'[", old_first)
		call setpos("']", old_last)
		let &selection = old_selection
		call winrestview(old_view)
		call setpos(".", old_pos)
	endtry
endfunction


function! s:get_text_line_from_lnum(first, last)
	return join(getline(a:first, a:last), "\n")
endfunction
"
"
" function! s:get_text_line_from_region(first, last)
" " 	if type(a:first) == type([])
" " 		return s:get_text_line_from_region(a:first[1], a:last)
" " 	elseif type(a:last) == type([])
" " 		return s:get_text_line_from_region(a:first, a:last[1])
" " 	endif
" " 	return join(getline(a:first, a:last), "\n")
"
" 	return s:get_text_line_from_lnum(a:first[1], a:last[1])
" endfunction


function! s:get_char_from_region(first, last)
	if a:first[1] == a:last[1]
		return getline(a:first[1])[a:first[2] - 1 : a:last[2] - 1]
	elseif (a:last[1] - a:first[1]) == 1
		return getline(a:first[1])[ a:first[2] - 1 : ] . "\n"
\			 . getline(a:last[1])[ : a:last[2] - 1]
	else
		return getline(a:first[1])[ a:first[2] - 1 : ] . "\n"
\			 . s:get_text_line_from_lnum(a:first[1] + 1, a:last[1] - 1)  . "\n"
\			 . getline(a:last[1])[ : a:last[2] - 1]
	endif
endfunction


function! s:get_block_from_region(first, last)
	let first = a:first
	let last  = a:last
	echo join(map(range(a:first[1], a:last[1]), "
\		s:get_char_from_region([first[0], v:val, first[2], first[3]], [last[0], v:val, last[2], last[3]])
\	"), "\n")
endfunction


function! s:get_text_from_region(first, last, ...)
	let wise = get(a:, 1, "v")
	if wise ==# "v"
		return s:get_char_from_region(a:first, a:last)
	elseif wise ==# "V"
		return s:get_line_from_region(a:first, a:last)
	elseif wise ==# "\<C-v>"
		return s:get_block_from_region(a:first, a:last)
	endif
" 	let old_first = getpos("'[")
" 	let old_last  = getpos("']")
" 	try
" 		call setpos("'[", a:first)
" 		call setpos("']", a:last)
" 		return s:get_text_from_latest_yank(wise)
" 	finally
" 		call setpos("'[", old_first)
" 		call setpos("']", old_last)
" 	endtry
endfunction


function! s:get_text_from_pattern(pattern)
	let [first, last] = s:Search.region(a:pattern, "Wncb", "Wnce")
	if first == [0, 0]
		return ""
	endif
	if last == [0, 0]
		return ""
	endif
	let result = s:get_text_from_region([0] + first + [0], [0] + last + [0], "v")
	if result !~ '^' . a:pattern . '$'
		return ""
	endif
	return result
endfunction


function! s:_as_config(config)
	let default = {
\		"textobj" : "",
\		"is_cursor_in" : 0,
\		"noremap" : 0,
\	}
	let config
\		= type(a:config) == type("") ? { "textobj" : a:config }
\		: type(a:config) == type({}) ? a:config
\		: {}
	return extend(default, config)
endfunction


let s:region = []
let s:wise = ""
function! s:_buffer_region_operator(wise)
	let reg_save = @@
	let s:wise = a:wise
	let s:region = [getpos("'[")[1:], getpos("']")[1:]]
	let @@ = reg_save
endfunction

nnoremap <silent> <Plug>(vital-coaster_buffer_region)
\	:<C-u>set operatorfunc=<SID>_buffer_region_operator<CR>g@


function! s:get_region_from_textobj(textobj)
	let s:region = []
	let config = s:_as_config(a:textobj)

	let winview = winsaveview()
	let pos = getpos(".")
	try
		silent execute (config.noremap ? 'onoremap' : 'omap') '<expr>'
\			'<Plug>(vital-coaster_buffer_region-target)' string(config.textobj)

		let tmp = &operatorfunc
		silent execute "normal \<Plug>(vital-coaster_buffer_region)\<Plug>(vital-coaster_buffer_region-target)"
		let &operatorfunc = tmp

		if !empty(s:region) && !s:pos_less_equal(s:region[0], s:region[1])
			return ["", []]
		endif
		if !empty(s:region) && config.is_cursor_in && (s:pos_less(pos[1:], s:region[0]) || s:pos_less(s:region[1], pos[1:]))
			return ["", []]
		endif
		return deepcopy([s:wise, s:region])
	finally
		call winrestview(winview)
		call cursor(pos[1], pos[2])
	endtry
endfunction


function! s:execute(expr, cmd)
	let bufnr = bufnr("%")
	try
		noautocmd execute "bufdo if bufnr('%') == " a:expr . ' | ' . a:cmd . ' | endif'
	finally
		execute "buffer" bufnr
	endtry
endfunction


function! s:setbufline(expr, lnum, text)
	return s:execute(a:expr, "call setline(" . a:lnum . "," . string(a:text) . ")")
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
