scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim

let s:V = vital#of("vital")
" let s:V = vital#of("brightest")
let s:Prelude = s:V.import("Prelude")
let s:Buffer = s:V.import("Coaster.Buffer")
let s:Search = s:V.import("Coaster.Search")
let s:Highlight = s:V.import("Coaster.Highlight")


let g:brightest#enable_filetypes = get(g:, "brightest#enable_filetypes", {})
" let g:brightest#enable_highlight_cursorline = get(g:, "brightest#enable_highlight_cursorline", 0)
" let g:brightest#highlight_format  = get(g:, "brightest#highlight_format", "\\<%s\\>")

let g:brightest#ignore_syntax_list = get(g:, "brightest#ignore_syntax_list", [])
let g:brightest#ignore_word_pattern = get(g:, "brightest#ignore_word_pattern", "")



function! s:context()
	return {
\		"filetype" : &filetype,
\		"line" : line("."),
\		"col"  : col("."),
\		"syntax_name" : synIDattr(synIDtrans(synID(line("."), col("."), 1)), "name")
\	}
endfunction


function! s:is_ignore_syntax_in_cursor(context)
	let list = get(b:, "brightest_ignore_syntax_list", g:brightest#ignore_syntax_list)

	if empty(list)
		return 0
	endif

	return index(list, a:context.syntax_name) != -1
endfunction


function! s:is_enable_in_current(context)
	let default = get(g:brightest#enable_filetypes, "_", 1)
	return get(g:brightest#enable_filetypes, a:context.filetype, default)
endfunction


function! s:is_ignore(context)
	return !s:is_enable_in_current(a:context) || s:is_ignore_syntax_in_cursor(a:context)
endfunction


let g:brightest#enable_highlight_all_window = get(g:, "brightest#enable_highlight_all_window", 0)
function! s:highlight_on()
	if g:brightest#enable_highlight_all_window
		call s:Highlight.as_windo().enable_all()
	else
		call s:Highlight.enable_all()
	endif
endfunction


function! s:highlight_off()
	if g:brightest#enable_highlight_all_window
		call s:Highlight.as_windo().disable_all()
	else
		call s:Highlight.disable_all()
	endif
endfunction


function! Test()
	call s:Highlight.as_windo().disable_all()
endfunction


let s:old_enable_window_all = g:brightest#enable_highlight_all_window
function! brightest#hl_clear()
	if empty(s:Highlight.hl_list())
		return
	endif
" 	call s:Highlight.as_windo().disable_all()
	if g:brightest#enable_highlight_all_window
\	|| s:old_enable_window_all
		call s:Highlight.as_windo().disable_all()
	endif
	call s:Highlight.clear_all()
	let s:old_enable_window_all = g:brightest#enable_highlight_all_window
endfunction

function! s:highlight(name, pattern, hi)
	if empty(a:hi) || empty(a:pattern) || a:hi.group == ""
		return
	endif
	let pattern = printf(a:hi.format, a:pattern)
	call s:Highlight.add(a:name, a:hi.group, pattern, a:hi.priority)
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

	let ignore_word_pattern = get(b:, "brightest_ignore_word_pattern", g:brightest#ignore_word_pattern)
	if !empty(ignore_word_pattern) && word =~ ignore_word_pattern
		return
	endif

	let pattern = s:Prelude.escape_pattern(word)

	if &cursorline && a:cursorline.group ==# "BrightestCursorLineBg"
		call brightest#define_cursorline_highlight_group(a:highlight.group)
	endif

	" nocursorline の場合、BrightestCursorLineBg でハイライトしない
	let is_highlight_cursorline
\		= !(a:cursorline.group ==# "BrightestCursorLineBg" && &cursorline == 0 || a:cursorline.group == "")

	if is_highlight_cursorline
		call s:highlight("cursor_line_over", '\%<' . line('.') . 'l' . pattern, a:highlight)
		call s:highlight("cursor_line_down", '\%>' . line('.') . 'l' . pattern, a:highlight)
	else
		call s:highlight("cursor_word", pattern, a:highlight)
	endif

	if is_highlight_cursorline
		call s:highlight("cursor_line", '\%' . line('.') . 'l' . pattern, a:cursorline)
	endif
	return 1
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

	let context = s:context()
	if s:is_ignore(context)
		return
	endif

	if get(a:, 1, "") == ""
		if s:single_word(a:pattern, a:highlight, a:cursorline)
			call s:highlight_on()
		endif
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
	return get(b:, "brightest_highlight", extend(copy(s:highlight_default), g:brightest#highlight))
endfunction


let s:highlight_in_cursorline_default = {
\	"group" : "",
\	"priority" : -1,
\	"format" : '\<%s\>',
\}
let g:brightest#highlight_in_cursorline = get(g:, "brightest#highlight_in_cursorline", {})
function! s:highlight_in_cursorline()
	return get(b:, "brightest_highlight_in_cursorline", extend(copy(s:highlight_in_cursorline_default), g:brightest#highlight_in_cursorline))
endfunction


function! brightest#highlighting()
	call s:highlighting(
\		get(b:, "brightest_pattern", g:brightest#pattern),
\		s:default(),
\		s:highlight_in_cursorline(),
\	)
endfunction


let s:parse_cursorline_highlight_group_memo = {}
function! brightest#parse_cursorline_highlight_group(group)
	redir => hl
		silent execute "highlight" a:group
	redir END
	let key = hl
	if has_key(s:parse_cursorline_highlight_group_memo, key)
		return s:parse_cursorline_highlight_group_memo[key]
	endif
	let hl = substitute(hl, '\n', '', 'g')
	let hl = matchstr(hl, '.*xxx\zs.*')
	let guibg   = synIDattr(synIDtrans(hlID("CursorLine")), "bg", "gui")
	if guibg != "" && guibg != -1
		if hl =~ 'guibg=\S\+'
			let hl = substitute(hl, 'guibg=\S\+', 'guibg=' . guibg, "")
		else
			let hl .= ' guibg=' . guibg
		endif
	endif

	let ctermbg = synIDattr(synIDtrans(hlID("CursorLine")), "bg", "cterm")
	if ctermbg != "" && ctermbg != -1
		if hl =~ 'ctermbg=\S\+'
			let hl = substitute(hl, 'ctermbg=\S\+', 'ctermbg=' . ctermbg, "")
		else
			let hl .= ' ctermbg=' . ctermbg
		endif
	endif
	let s:parse_cursorline_highlight_group_memo[key] = hl
	return hl
endfunction


function! brightest#define_cursorline_highlight_group(group)
	highlight BrightestCursorLineBg NONE
	execute "highlight BrightestCursorLineBg " . brightest#parse_cursorline_highlight_group(a:group)
endfunction


let g:brightest#enable_insert_mode = get(g:, "brightest#enable_insert_mode", 0)


function! s:is_enable()
	return get(g:, "brightest_enable", 1) && get(b:, "brightest_enable", 1)
endfunction

let g:brightest#enable_on_CursorHold = get(g:, "brightest#enable_on_CursorHold", 0)

function! s:is_enable_on_cursorhold()
	return g:brightest#enable_on_CursorHold && get(b:, "brightest_enable_on_CursorHold", 1)
endfunction


let s:is_CursorMoved = 1
function! brightest#on_CursorHold()
	" Workaround : call the CursorMoved to the next CursorHold
	" call feedkeys(mode() ==# 'i' ? "\<C-g>\<ESC>" : "g\<ESC>", 'n')
	if s:is_enable() && s:is_enable_on_cursorhold() && s:is_CursorMoved
		call brightest#highlighting()
	endif
	let s:is_CursorMoved = 0
endfunction


let g:brightest#enable_clear_highlight_on_CursorMoved = get(g:, "brightest#enable_clear_highlight_on_CursorMoved", 1)

function! brightest#on_CursorMoved()
	let s:is_CursorMoved = 1
	let mode = mode()

	if s:is_enable_on_cursorhold() && g:brightest#enable_clear_highlight_on_CursorMoved
		call brightest#hl_clear()
	endif
	if s:is_enable() && !s:is_enable_on_cursorhold()
		call brightest#highlighting()
	endif

	" Workaround : visual mode to normal mode
	" https://github.com/osyo-manga/vim-brightest/issues/13
	if mode =~# "[\<C-v>vV]" && mode != mode()
\	&& g:brightest#enable_highlight_all_window
		normal! gv
	endif
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
