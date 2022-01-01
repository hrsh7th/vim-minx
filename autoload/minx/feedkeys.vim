let s:undojoin = minx#string#termcodes('<C-g>U')
let s:left = minx#string#termcodes('<Left>')
let s:right = minx#string#termcodes('<Right>')

"
" Key stack.
"
let s:stack = []

"
" minx#feedkeys#do
"
function! minx#feedkeys#do(steps) abort
  let l:run = len(s:stack) == 0
  for l:Step in reverse(deepcopy(type(a:steps) == v:t_list ? a:steps : [a:steps]))
    call add(s:stack, l:Step)
  endfor
  if l:run
    call feedkeys("\<Cmd>call minx#feedkeys#_pop()\<CR>", 'n')
  endif
endfunction

"
" minx#feedkeys#_pop
"
function! minx#feedkeys#_pop() abort
  if len(s:stack) == 0
    return
  endif
  let l:step = s:step(remove(s:stack, len(s:stack) - 1))
  let l:keys = minx#string#termcodes(l:step.keys)
  let l:keys = substitute(l:keys, s:undojoin, '', 'g')
  let l:keys = substitute(l:keys, s:left, s:undojoin .. s:left, 'g')
  let l:keys = substitute(l:keys, s:right, s:undojoin .. s:right, 'g')
  call feedkeys("\<Cmd>call minx#feedkeys#_pop()\<CR>", 'in')
  call feedkeys(l:keys, 'i' .. (l:step.noremap ? 'n' : 'm'))
endfunction

"
" s:step
"
function! s:step(Step) abort
  if type(a:Step) == v:t_string
    return { 'keys': a:Step, 'noremap': v:true }
  elseif type(a:Step) == v:t_func
    return s:step(a:Step())
  endif
  return a:Step
endfunction

