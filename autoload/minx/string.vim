"
" minx#string#termcodes
"
function! minx#string#termcodes(input) abort
  return substitute(a:input, '\(<[A-Za-z0-9\-\[\]^_@]\{-}>\)', { m -> eval('"\' .. m[0] .. '"') }, 'g')
endfunction

"
" minx#string#input
"
function! minx#string#input(input) abort
  let l:codes = minx#string#termcodes(a:input)
  let l:codes = substitute(l:codes, s:undojoin, '', 'g')
  let l:codes = substitute(l:codes, '\%(' .. s:undobreak .. '\)\@<!' .. s:left, s:undojoin .. s:left, 'g')
  let l:codes = substitute(l:codes,  '\%(' .. s:undobreak .. '\)\@<!' .. s:right, s:undojoin .. s:right, 'g')
  return l:codes
endfunction

let s:undobreak = minx#string#termcodes('<C-g>u')
let s:undojoin = minx#string#termcodes('<C-g>U')
let s:left = minx#string#termcodes('<Left>')
let s:right = minx#string#termcodes('<Right>')

