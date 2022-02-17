let s:entry_id = 0

let s:state = {
\   'chars': {},
\ }

"
" minx#add
"
function! minx#add(char, entry) abort
  let l:char_id = minx#serialize#to_id(a:char)
  if !has_key(s:state.chars, l:char_id)
    call execute(printf('inoremap <silent> %s <Cmd>call feedkeys(minx#expand(minx#serialize#from_id(%s)), "ni")<CR>', a:char, l:char_id))
    let s:state.chars[l:char_id] = { 'entries': [] }
  endif

  " Add entry.
  let s:entry_id += 1
  let s:state.chars[l:char_id].entries += [s:entry(s:entry_id, a:entry)]
  let s:state.chars[l:char_id].entries = s:sorted(s:state.chars[l:char_id].entries)
endfunction

"
" minx#expand
"
function! minx#expand(char) abort
  let l:char_id = minx#serialize#to_id(a:char)
  for l:entry in get(s:state.chars, l:char_id, { 'entries': [] }).entries
    if l:entry.ok()
      let l:pos = searchpos(l:entry.at, 'znc')
      if l:pos[0] != 0
        return printf("\<Cmd>call minx#feedkeys#do(minx#serialize#from_id(%s))\<CR>", minx#serialize#to_id(l:entry.keys))
      endif
    endif
  endfor
  return minx#string#termcodes(a:char)
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
    \   'ok': { -> v:true },
    \   'keys': a:entry,
    \ }
  endif
  return {
  \   'id': a:entry_id,
  \   'priority': get(a:entry, 'priority', 0),
  \   'at': get(a:entry, 'at', '\%#'),
  \   'ok': { -> v:true },
  \   'keys': get(a:entry, 'keys', ''),
  \ }
endfunction

