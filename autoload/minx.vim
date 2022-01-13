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
  if type(a:entry) != v:t_dict
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

