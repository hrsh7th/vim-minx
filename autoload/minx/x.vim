"
" minx#x#enterpair
"
function! minx#x#enterpair() abort
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
" minx#x#capture
"
function! minx#x#capture(...) abort
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
" minx#x#search
"
function! minx#x#search(...) abort
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
" minx#x#searchpair
"
function! minx#x#searchpair(...) abort
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

