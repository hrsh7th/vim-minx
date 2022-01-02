let s:id = 0
let s:str2id = {}
let s:id2str = {}

"
" minx#string#to_id
"
function! minx#string#to_id(str) abort
  if !has_key(s:str2id, a:str)
    let s:id += 1
    let s:str2id[a:str] = s:id
    let s:id2str[s:id] = a:str
  endif
  return s:str2id[a:str]
endfunction

"
" minx#string#from_id
"
function! minx#string#from_id(id) abort
  return s:id2str[a:id]
endfunction

"
" minx#string#normalize
"
function! minx#string#normalize(char) abort
  call execute(printf('tnoremap <Plug>(minx:normalize) %s', a:char))
  return maparg('<Plug>(minx:normalize)', 't')
endfunction

"
" termcodes
"
function! minx#string#termcodes(input) abort
  return substitute(a:input, '\(<[A-Za-z0-9\-\[\]^_@]\{-}>\)', { m -> eval('"\' .. m[0] .. '"') }, 'g')
endfunction

