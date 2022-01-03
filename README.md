# vim-minx

Extended insert-mode key mapping manager.

## Usage

```vim
function! s:e(str) abort
  return '\V' .. a:str .. '\m'
endfunction

let s:pairs = { '(': ')', '[': ']', '{': '}', '<': '>' }
let s:quotes = { '"': '"', "'": "'" }

" Close.
for [s:o, s:c] in items(extend(copy(s:pairs), s:quotes))
  call minx#add(s:o, s:o .. s:c .. '<Left>')
endfor

" Leave.
for [s:o, s:c] in items(extend(copy(s:pairs), s:quotes))
  call minx#add('<Tab>', {
  \   'at': '\%#\s*\V' .. s:c,
  \   'keys': [minx#search('\V' .. s:c .. '\m\zs')],
  \ })
endfor

" Space.
for [s:o, s:c] in items(extend(copy(s:pairs), s:quotes))
  call minx#add('<Space>', {
  \   'at': s:e(s:o) ..  '\s*\%#\s*' .. s:e(s:c),
  \   'keys': '<Space><Space><Left>'
  \ })
endfor

" Delete.
for [s:o, s:c] in items(extend(copy(s:pairs), s:quotes))
  call minx#add('<BS>', {
  \   'at': s:e(s:o) ..  '\s*\%#\s*' .. s:e(s:c),
  \   'keys': '<BS><Del>'
  \ })
endfor

" Enter.
for [s:o, s:c] in items(extend(copy(s:pairs), s:quotes))
  call minx#add('<CR>', {
  \   'at': s:e(s:o) ..  '\%#' .. s:e(s:c),
  \   'keys': ['<CR>', '<C-o>k', '<C-o>$', '<CR>']
  \ })
endfor

" Wrap contents.
for [s:o, s:c] in items(copy(s:pairs))
  " quotes.
  for [s:target_o, s:target_c] in items(s:quotes)
    call minx#add(s:c, {
    \   'priority': 3,
    \   'at': '\%#' .. s:e(s:c) .. '\s*\k*' .. s:e(s:target_o) .. '.\{-}' .. s:e(s:target_c),
    \   'keys': ['<Del>', minx#search(s:e(s:target_o) .. '\zs'), minx#search('\\\@<!' .. s:e(s:target_c) .. '\zs'), s:c, '<Left>']
    \ })
  endfor

  " pairs.
  for [s:target_o, s:target_c] in items(s:pairs)
    call minx#add(s:c, {
    \   'priority': 2,
    \   'at': '\%#' .. s:e(s:c) .. '\s*\k*' .. s:e(s:target_o) .. '.\{-}' .. s:e(s:target_c),
    \   'keys': ['<Del>', minx#search(s:e(s:c) .. '\zs'), minx#searchpair(s:e(s:target_o), '', s:e(s:target_c)), s:c, '<Left>']
    \ })
  endfor

  " keywords.
  call minx#add(s:c, {
  \   'priority': 1,
  \   'at': '\%#' .. s:e(s:c) ..  '\s*\k*',
  \   'keys': ['<Del>', minx#search('\s*\k\+\zs'), s:c, '<Left>']
  \ })
endfor
```

