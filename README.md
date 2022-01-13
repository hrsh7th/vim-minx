## Example

```
  let s:pairs = { '(': ')', '[': ']', '{': '}', '<': '>' }
  let s:quotes = { '"': '"', "'": "'", '`': '`' }

  " Semicolon
  call minx#add('<Tab>', {
  \   'at': '\%#\%(;\|`\)',
  \   'keys': '<Right>',
  \ })

  " Auto.
  for [s:o, s:c] in items(extend(copy(s:pairs), s:quotes))
    call minx#add(s:o, s:o .. s:c .. '<Left>')
  endfor

  " Leave.
  for [s:o, s:c] in items(extend(copy(s:pairs), s:quotes))
    call minx#add('<Tab>', {
    \   'at': '\%#\s*' .. minx#u#e(s:c),
    \   'keys': [minx#x#search('\V' .. s:c .. '\m\zs')],
    \ })
  endfor

  " Space.
  for [s:o, s:c] in items(extend(copy(s:pairs), s:quotes))
    call minx#add('<Space>', {
    \   'at': minx#u#e(s:o) ..  '\s*\%#\s*' .. minx#u#e(s:c),
    \   'keys': '<Space><Space><Left>'
    \ })
  endfor

  " Remove.
  for [s:o, s:c] in items(extend(copy(s:pairs), s:quotes))
    call minx#add('<BS>', {
    \   'at': minx#u#e(s:o) ..  '\s*\%#\s*' .. minx#u#e(s:c),
    \   'keys': '<BS><Del>'
    \ })
  endfor

  " Enter.
  for [s:o, s:c] in items(copy(s:pairs))
    call minx#add('<CR>', {
    \   'at': minx#u#e(s:o) ..  '\%#' .. minx#u#e(s:c),
    \   'keys': [minx#x#enterpair()]
    \ })
  endfor
  call minx#add('<CR>', {
  \   'priority': -1,
  \   'at': '<\w\+\%(\s\+.\{-}\)\?>\%#$',
  \   'keys': ['</', minx#x#capture('<\(\w\+\)\%(\s\+.\{-}\)\?></\%#'), '>', minx#x#search('<\w\+\%(\s\+.\{-}\)\?>\zs</\w\+>\%#'), minx#x#enterpair()]
  \ })
  call minx#add('<CR>', {
  \   'at': '>\%#<',
  \   'keys': [minx#x#enterpair()]
  \ })

  " Wrap contents.
  for [s:o, s:c] in items(copy(s:pairs))
    " quotes.
    for [s:target_o, s:target_c] in items(s:quotes)
      call minx#add(s:c, {
      \   'priority': 3,
      \   'at': '\%#' .. minx#u#e(s:c) .. '\s*' .. minx#u#e(s:target_o),
      \   'keys': ['<Del>', minx#x#search(minx#u#e(s:target_o) .. '\zs'), minx#x#search('\\\@<!' .. minx#u#e(s:target_c) .. '\zs'), s:c, '<Left>']
      \ })
    endfor

    " pairs.
    for [s:target_o, s:target_c] in items(s:pairs)
      call minx#add(s:c, {
      \   'priority': 2,
      \   'at': '\%#' .. minx#u#e(s:c) .. '\s*[^[:blank:]]*' .. minx#u#e(s:target_o),
      \   'keys': ['<Del>', minx#x#search(minx#u#e(s:target_o) .. '\zs'), minx#x#searchpair(minx#u#e(s:target_o), '', minx#u#e(s:target_c)), '<Right>', s:c, '<Left>']
      \ })
    endfor

    " keywords.
    call minx#add(s:c, {
    \   'priority': 1,
    \   'at': '\%#' .. minx#u#e(s:c) ..  '\s*[^[:blank:]]\+',
    \   'keys': ['<Del>', minx#x#search('\s*[^[:blank:]]\+\zs'), s:c, '<Left>']
    \ })
  endfor

```

