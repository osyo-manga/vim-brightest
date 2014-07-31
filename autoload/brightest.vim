scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim

let s:V = vital#of("brightest")
let s:Prelude = s:V.import("Prelude")
let s:Buffer = s:V.import("Coaster.Buffer")
let s:Highlight = s:V.import("Coaster.Highlight")
let s:Search = s:V.import("Coaster.Search")


let g:brightest#enable_filetypes = get(g:, "brightest#enable_filetypes", {})
" let g:brightest#highlight_format  = get(g:, "brightest#highlight_format", "\\<%s\\>")


function! s:is_enable_in_current()
	let default = get(g:brightest#enable_filetypes, "_", 1)
	return g:brightest_enable && get(g:brightest#enable_filetypes, &filetype, default)
endfunction


function! brightest#hl_clear()
	call s:Highlight.clear("cursor_word")
	call s:Highlight.clear("cursor_line")
	call s:Highlight.clear("current_word")
endfunction


function! s:highlight(name, pattern, hi)
	if empty(a:hi) || empty(a:pattern) || a:hi.group == ""
		return
	endif
	let pattern = printf(a:hi.format, a:pattern)
	call s:Highlight.highlight(a:name, a:hi.group, pattern, a:hi.priority)
endfunction


function! s:single_word(pattern, highlight, cursorline)
	let pattern = a:pattern
	if pattern ==# ""
		let word = expand("<cword>")
	else
		let word = s:Buffer.get_text_from_pattern(pattern)
	endif

	" マルチバイト文字はハイライトしない
	if word == ""
\	|| !empty(filter(split(word, '\zs'), "strlen(v:val) > 1"))
		return
	endif

	let pattern = s:Prelude.escape_pattern(word)
	call s:highlight("cursor_word", pattern, a:highlight)
	call s:highlight("cursor_line", '\%' . line('.') . 'l' . pattern, a:cursorline)
endfunction


" function! s:with_current(current_group, group, pattern)
" 	let [first, last] = s:Search.region(a:pattern, "Wncb", "Wnce")
" 	if first == [0, 0] || last == [0, 0]
" 		return
" 	endif
" 	let word = s:Buffer.get_text_from_region([0] + first + [0], [0] + last + [0], "v")
" 	if word !~ '^' . a:pattern . '$'
" 		return
" 	endif
" 	let current = s:Search.pattern_by_range("v", first, last)
"
" 	" マルチバイト文字はハイライトしない
" 	if !empty(filter(split(word, '\zs'), "strlen(v:val) > 1"))
" 		return
" 	endif
"
" 	let pattern = printf(g:brightest#highlight_format, s:Prelude.escape_pattern(word))
"
" 	call s:Highlight.highlight("cursor_word", a:group, pattern, -1)
" 	call s:Highlight.highlight("current_word", a:current_group, current, -1)
" endfunction


function! s:highlighting(pattern, highlight, cursorline, ...)
	call brightest#hl_clear()
	
	if !s:is_enable_in_current()
		return
	endif

	if get(a:, 1, "") == ""
		return s:single_word(a:pattern, a:highlight, a:cursorline)
	else
" 		return s:with_current(a:1, a:group, a:pattern)
	endif
endfunction



let g:brightest#pattern = get(g:, "brightest#pattern",  '')


let s:highlight_default = {
\	"group" : "WarningMsg",
\	"priority" : -1,
\	"format" : '\<%s\>',
\}
let g:brightest#highlight = get(g:, "brightest#highlight", {})
function! s:default()
	return get(b:, "brightest_highlight", extend(s:highlight_default, g:brightest#highlight))
endfunction


let s:highlight_in_cursorline_default = {
\	"group" : "",
\	"priority" : -1,
\	"format" : '\<%s\>',
\}
let g:brightest#highlight_in_cursorline = get(g:, "brightest#highlight_in_cursorline", {})
function! s:highlight_in_cursorline()
	return get(b:, "brightest_highlight_in_cursorline", extend(s:highlight_in_cursorline_default, g:brightest#highlight_in_cursorline))
endfunction


function! brightest#highlighting()
	call s:highlighting(
\		get(b:, "brightest_pattern", g:brightest#pattern),
\		s:default(),
\		s:highlight_in_cursorline(),
\	)
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
