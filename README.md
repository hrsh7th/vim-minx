# vim-minx

Extended insert-mode key mapping manager.

## Usage

```vim
call minx#add('(', '()<Left>')
call minx#add('(', '()<Right>')

let s:pairs = { '(': ')', '[': ']', '{': '}', '<': '>' }
let s:quotes = { '"': '"', "'": "'" }

" Backspace.
for [s:lhs, s:rhs] in items(extend(copy(s:pairs), s:quotes))
  call minx#add('<BS>', {
  \   'at': '\V' .. s:lhs ..  '\m\s*\%#\s*\V' .. s:rhs,
  \   'keys': '<BS><Del>'
  \ })
endfor

" Space.
for [s:lhs, s:rhs] in items(extend(copy(s:pairs), s:quotes))
  call minx#add('<BS>', {
  \   'at': '\V' .. s:lhs ..  '\m\s*\%#\s*\V' .. s:rhs,
  \   'keys': '<Space><Space><Left>'
  \ })
endfor

" Enter.
for [s:lhs, s:rhs] in items({ '(': ')', '[': ']', '{': '}', '<': '>' })
  call minx#add('<CR>', {
  \   'at': '\V' .. s:lhs ..  '\m\s*\%#\s*\V' .. s:rhs,
  \   'keys': ['<CR>', '<C-o>k', '<C-o>$', '<CR>']
  \ })
endfor
```

