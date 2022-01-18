let s:id = 0
let s:val2id = {}
let s:id2val = {}

"
" minx#serialize#to_id
"
function! minx#serialize#to_id(val) abort
  let l:s = string(a:val)
  if !has_key(s:val2id, l:s)
    let s:id += 1
    let s:val2id[l:s] = s:id
    let s:id2val[s:id] = a:val
  endif
  return s:val2id[l:s]
endfunction

"
" minx#serialize#from_id
"
function! minx#serialize#from_id(id) abort
  return s:id2val[a:id]
endfunction
