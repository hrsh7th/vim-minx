let s:marks = {}

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

"
" minx#x#mark
"
function! minx#x#mark(...) abort
  let l:ctx = {}
  function! l:ctx.callback(name) abort
    let s:marks[a:name] = getcurpos()[1:2]
    return ''
  endfunction
  return function(l:ctx.callback, a:000, l:ctx)
endfunction

"
" minx#x#back
"
function! minx#x#back(...) abort
  let l:ctx = {}
  function! l:ctx.callback(name) abort
    return minx#u#move(get(s:marks, a:name, getcurpos()[1:2]))
  endfunction
  return function(l:ctx.callback, a:000, l:ctx)
endfunction

