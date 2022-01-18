"
" minx#x#token
"
function! minx#x#token() abort
  return function('minx#u#token', a:000)
endfunction

"
" minx##white
"
function! minx#x#white() abort
  return function('minx#u#white', a:000)
endfunction

"
" minx#x#enterpair
"
function! minx#x#enterpair(...) abort
  return function('minx#u#enterpair', a:000)
endfunction

"
" minx#x#capture
"
function! minx#x#capture(...) abort
  return function('minx#u#capture', a:000)
endfunction

"
" minx#x#search
"
function! minx#x#search(...) abort
  return function('minx#u#search', a:000)
endfunction

"
" minx#x#searchpair
"
function! minx#x#searchpair(...) abort
  return function('minx#u#searchpair', a:000)
endfunction

