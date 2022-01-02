let s:entry_id = 0

let s:state = {
\   'chars': {},
\ }

"
" minx#add
"
function! minx#add(char, entry) abort
  let l:char = minx#string#normalize(a:char)
  if !has_key(s:state.chars, l:char)
    let s:state.chars[l:char] = { 'entries': {} }
    call nvim_set_keymap('i', l:char, printf('<SNR>%s_on_char(%s)', s:SID(), minx#string#to_id(l:char)), {
    \   'noremap': v:true,
    \   'expr': v:true
    \ })
  endif

  " Add entry.
  let s:entry_id += 1
  let s:state.chars[l:char].entries[s:entry_id] = s:entry(s:entry_id, a:entry)
endfunction

"
" minx#expand
"
function! minx#expand(char) abort
  let l:char = minx#string#normalize(a:char)
  for [l:entry_id, l:entry] in items(s:state.chars[l:char].entries)
    let l:pos = searchpos(l:entry.at, 'zn')
    if l:pos[0] != 0
      return printf("\<Cmd>call <SNR>%d_on_entry(%s, %s)\<CR>", s:SID(), minx#string#to_id(l:char), l:entry_id)
    endif
  endfor
  return minx#string#termcodes(l:char)
endfunction

"
" minx#search
"
function! minx#search(...) abort
  let l:ctx = {}
  function! l:ctx.callback(...) abort
    let l:pattern = get(a:000, 0, '')
    let l:flags = get(a:000, 1, 'znc') .. 'n'
    let l:stopline = get(a:000, 2, 0) + line('.')
    let l:timeout = get(a:000, 3, 200)
    let l:pos = searchpos(l:pattern, l:flags, l:stopline, l:timeout)
    if l:pos[0] == 0
      return ''
    endif
    return s:move(l:pos)
  endfunction
  return function(l:ctx.callback, a:000, l:ctx)
endfunction

"
" minx#searchpair
"
function! minx#searchpair(...) abort
  let l:ctx = {}
  function! l:ctx.callback(...) abort
    let l:start = get(a:000, 0, '')
    let l:middle = get(a:000, 1, '')
    let l:end = get(a:000, 2, '')
    let l:flags = get(a:000, 3, 'znc') .. 'n'
    let l:skip = get(a:000, 4, '')
    let l:stopline = get(a:000, 2, 0) + line('.')
    let l:timeout = get(a:000, 6, 200)

    let l:pos = searchpairpos(l:start, l:middle, l:end, l:flags, l:skip, l:stopline, l:timeout)
    if l:pos[0] == 0
      return ''
    endif
    return s:move(l:pos)
  endfunction
  return function(l:ctx.callback, a:000, l:ctx)
endfunction

"
" s:move
"
function! s:move(pos) abort
  if a:pos[0] ==# line('.')
    let l:delta = a:pos[1] - col('.')
    if l:delta > 0
      return repeat('<Right>', l:delta)
    elseif l:delta < 0
      return repeat('<Left>', l:delta)
    endif
    return ''
  endif
  return ''
endfunction

"
" s:on_char
"
function! s:on_char(char_id) abort
  return minx#expand(minx#string#from_id(a:char_id))
endfunction

"
" s:on_entry
"
function! s:on_entry(char_id, entry_id) abort
  let l:char = minx#string#from_id(a:char_id) 
  if !has_key(s:state.chars, l:char)
    return minx#string#termcodes(l:char, v:true, v:true, v:true)
  endif

  let l:entry = s:state.chars[l:char].entries[a:entry_id]
  call minx#feedkeys#do(l:entry.keys)
  return ''
endfunction

"
" s:sorted
"
function! s:sorted(entries) abort
  function! s:compare(a, b) abort
    if a:a.priority != a:b.priority
      return a:b.priority - a:b.priority
    endif
    let l:alen = strlen(a:a.at)
    let l:blen = strlen(a:b.at)
    if l:alen != l:blen
      return l:blen - l:alen
    endif
    return a:a.id - a:b.id
  endfunction
  return sort(copy(a:entries), function('s:compare'))
endfunction

"
" s:entry
"
function! s:entry(entry_id, entry) abort
  if type(a:entry) == v:t_string
    return {
    \   'id': a:entry_id,
    \   'priority': 0,
    \   'at': '\%#',
    \   'keys': a:entry,
    \ }
  endif
  return {
  \   'id': a:entry_id,
  \   'priority': get(a:entry, 'priority', 0),
  \   'at': get(a:entry, 'at', '\%#'),
  \   'keys': get(a:entry, 'keys', ''),
  \ }
endfunction

"
" Get script id that uses to call `s:` function in feedkeys.
"
function! s:SID() abort
  return matchstr(expand('<sfile>'), '<SNR>\zs\d\+\ze_SID$')
endfunction

