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
    call feedkeys("\<Cmd>call minx#feedkeys#pop()\<CR>", 'in')
  endif
  let s:stack += reverse(deepcopy(type(a:steps) == v:t_list ? a:steps : [a:steps]))
endfunction

"
" minx#feedkeys#pop
"
function! minx#feedkeys#pop() abort
  if mode(1) ==# 'c'
    augroup minx#feedkeys#_pop
      autocmd!
      autocmd CmdlineLeave * ++once call feedkeys("\<Cmd>call minx#feedkeys#pop()\<CR>", 'in')
    augroup END
    return
  endif
  if len(s:stack) == 0
    return
  endif

  call feedkeys("\<Cmd>call minx#feedkeys#pop()\<CR>", 'in')
  try
    let l:step = s:step(remove(s:stack, len(s:stack) - 1))
    if type(l:step) == v:t_list
      return minx#feedkeys#do(l:step)
    endif
    if type(l:step) == v:t_dict
      let l:keys = minx#string#termcodes(l:step.keys)
      let l:keys = substitute(l:keys, s:undojoin, '', 'g')
      let l:keys = substitute(l:keys, '\%(' .. s:undobreak .. '\)\@<!' .. s:left, s:undojoin .. s:left, 'g')
      let l:keys = substitute(l:keys,  '\%(' .. s:undobreak .. '\)\@<!' .. s:right, s:undojoin .. s:right, 'g')
      call feedkeys(l:keys, l:step.noremap ? 'tin' : 'tim')
    endif
  catch /.*/
    echomsg string({ 'exception': v:exception, 'throwpoint': v:throwpoint })
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

