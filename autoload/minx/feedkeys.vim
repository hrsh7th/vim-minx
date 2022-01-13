let s:undobreak = minx#string#termcodes('<C-g>u')
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
  if len(s:stack) == 0
    call feedkeys("\<Cmd>call minx#feedkeys#_pop()\<CR>", 'n')
  endif
  let s:stack += reverse(deepcopy(type(a:steps) == v:t_list ? a:steps : [a:steps]))
endfunction

"
" minx#feedkeys#_pop
"
function! minx#feedkeys#_pop() abort
  if mode(1) ==# 'c'
    augroup minx#feedkeys#_pop
      autocmd!
      autocmd CmdlineLeave * ++once call feedkeys("\<Cmd>call minx#feedkeys#_pop()\<CR>", 'n')
    augroup END
    return
  endif
  if len(s:stack) == 0
    return
  endif
  try
    let l:Head = remove(s:stack, len(s:stack) - 1)
    let l:step = s:step(l:Head)
    let l:keys = minx#string#termcodes(l:step.keys)
    let l:keys = substitute(l:keys, s:undojoin, '', 'g')
    let l:keys = substitute(l:keys, '\%(' .. s:undobreak .. '\)\@<!' .. s:left, s:undojoin .. s:left, 'g')
    let l:keys = substitute(l:keys,  '\%(' .. s:undobreak .. '\)\@<!' .. s:right, s:undojoin .. s:right, 'g')
    call feedkeys("\<Cmd>call minx#feedkeys#_pop()\<CR>", 'in')
    call feedkeys(l:keys, l:step.noremap ? 'in' : 'im')
  catch /.*/
    echomsg string({ 'exception': v:exception, 'throwpoint': v:throwpoint, 'head': l:Head })
  endtry
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

