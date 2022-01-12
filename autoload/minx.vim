let s:entry_id = 0

let s:state = {
\   'chars': {},
\ }

"
" minx#add
"
function! minx#add(char, entry) abort
  let l:codes = minx#string#termcodes(a:char)
  if !has_key(s:state.chars, l:codes)
    call execute(printf('inoremap <expr> %s <SID>on_char(%s)', a:char, minx#string#to_id(l:codes)))
    let s:state.chars[l:codes] = { 'entries': [] }
  endif

  " Add entry.
  let s:entry_id += 1
  let s:state.chars[l:codes].entries += [s:entry(s:entry_id, a:entry)]
  let s:state.chars[l:codes].entries = s:sorted(s:state.chars[l:codes].entries)
endfunction

"
" minx#expand
"
function! minx#expand(char) abort
  let l:codes = minx#string#termcodes(a:char)
  for l:entry in get(s:state.chars, l:codes, { 'entries': [] }).entries
    let l:pos = searchpos(l:entry.at, 'znc')
    if l:pos[0] != 0
      return printf("\<Cmd>call <SNR>%d_on_entry(%s, %s)\<CR>", s:SID(), minx#string#to_id(l:codes), l:entry.id)
    endif
  endfor
  return l:codes
endfunction

"
" minx#enter
"
function! minx#enter() abort
  let l:ctx = {}
  function! l:ctx.callback(...) abort
    let l:current = getline('.')
    let l:one_indent = !&expandtab ? "\t" : repeat(' ', &shiftwidth ? &shiftwidth : &tabstop)
    let l:base_indent = matchstr(l:current, '^\s*')
    let l:text = "\n" .. l:base_indent .. l:one_indent .. "\n" .. l:base_indent
    execute printf('noautocmd keeppatterns keepjumps silent substitute/\%%#/\=l:text/%se', &gdefault ? 'g' : '')
    return printf('<Cmd>call cursor(%s, %s)<CR>', line('.') - 1, strlen(l:base_indent) + strlen(l:one_indent) + 1)
  endfunction
  return function(l:ctx.callback, a:000, l:ctx)
endfunction

"
" minx#capture
"
function! minx#capture(...) abort
  let l:ctx = {}
  function! l:ctx.callback(pattern) abort
    let l:pos = searchpos(a:pattern, 'zncp')
    if l:pos[0] == 0 || l:pos[2] == 0
      return ''
    endif
    return matchlist(getline(l:pos[0])[l:pos[1] - 1 : -1], substitute(a:pattern, '\\%#', '', 'g'))[1]
  endfunction
  return function(l:ctx.callback, a:000, l:ctx)
endfunction

"
" minx#search
"
function! minx#search(...) abort
  let l:ctx = {}
  function! l:ctx.callback(pattern) abort
    let l:pos = searchpos(a:pattern, 'znc')
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
    let l:pos = searchpairpos(l:start, l:middle, l:end, 'znc')
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
      return repeat('<Left>', abs(l:delta))
    endif
    return ''
  endif
  return printf('<C-o>:<C-u>call cursor(%s, %s)<CR>', a:pos[0], a:pos[1])
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
  let l:codes = minx#string#from_id(a:char_id) 
  if !has_key(s:state.chars, l:codes)
    return l:codes
  endif

  for l:entry in s:state.chars[l:codes].entries
    if l:entry.id == a:entry_id
      call minx#feedkeys#do(l:entry.keys)
      break
    endif
  endfor
  return ''
endfunction

"
" s:sorted
"
function! s:sorted(entries) abort
  function! s:compare(a, b) abort
    if a:a.priority != a:b.priority
      return a:b.priority - a:a.priority
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

