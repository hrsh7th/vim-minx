"
" minx#u#e
"
function! minx#u#e(text) abort
  return '\V' .. a:text .. '\m'
endfunction

"
" minx#u#enterpair
"
function! minx#u#enterpair() abort
  let l:one_indent = !&expandtab ? "\t" : repeat(' ', &shiftwidth ? &shiftwidth : &tabstop)
  let l:base_indent = matchstr(getline('.'), '^\s*')
  let l:keys = ''
  let l:keys .= '<Cmd>set paste<CR>'
  let l:keys .= '<CR>' .. l:base_indent .. l:one_indent .. '<CR>' .. l:base_indent
  let l:keys .= printf('<Cmd>set %spaste<CR>', &paste ? '' : 'no')
  let l:keys .= printf('<Cmd>call cursor(%s, %s)<CR>', line('.') + 1, strlen(l:base_indent .. l:one_indent) + 1)
  return l:keys
endfunction

"
" minx#u#capture
"
function! minx#u#capture(pattern) abort
  let l:pos = searchpos(a:pattern, 'zncp')
  if l:pos[0] == 0 || l:pos[2] == 0
    return ''
  endif
  return matchlist(getline(l:pos[0])[l:pos[1] - 1 : -1], substitute(a:pattern, '\\%#', '', 'g'))[1]
endfunction

"
" minx#u#search
"
function! minx#u#search(pattern) abort
  let l:pos = searchpos(a:pattern, 'znc')
  if l:pos[0] == 0
    return ''
  endif
  return s:move(l:pos)
endfunction

"
" minx#u#searchpair
"
function! minx#u#searchpair(start, middle, end) abort
  let l:pos = searchpairpos(a:start, a:middle, a:end, 'znc')
  if l:pos[0] == 0
    return ''
  endif
  return s:move(l:pos)
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


