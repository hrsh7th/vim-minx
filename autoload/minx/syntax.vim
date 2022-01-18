"
" minx#syntax#in
"
function! minx#syntax#in(group_name, ...) abort
  let l:group_names = minx#syntax#get(get(a:000, 0, getcurpos()[1 : 2]))
  for l:group_name in (type(a:group_name) == v:t_list ? a:group_name : [a:group_name])
    if index(l:group_names, l:group_name) != -1
      return v:true
    endif
  endfor
  return v:false
endfunction

"
" minx#syntax#get
"
function! minx#syntax#get(...) abort
  let l:curpos = get(a:000, 0, getcurpos()[1:2])
  return s:get_syntax_groups(l:curpos) + s:get_treesitter_syntax_groups([l:curpos[0] - 1, l:curpos[1] - 1])
endfunction

"
" s:get_syntax_groups
"
function! s:get_syntax_groups(curpos) abort
  let l:group_names = []
  for l:syn_id in call('synstack', a:curpos)
    call add(l:group_names, synIDattr(synIDtrans(l:syn_id), 'name'))
  endfor
  return l:group_names
endfunction

"
" s:get_treesitter_syntax_groups
"
function! s:get_treesitter_syntax_groups(curpos) abort
  if !has('nvim')
    return []
  endif
  return luaeval('_G.minx.syntax.get_treesitter_syntax_groups(_A)', a:curpos)
endfunction
lua <<EOF
  _G.minx = _G.minx or {}
  _G.minx.syntax = _G.minx.syntax or {}
  _G.minx.syntax.get_treesitter_syntax_groups = function(cursor)
    local bufnr = vim.api.nvim_get_current_buf()
    local highlighter = vim.treesitter.highlighter.active[bufnr]
    if not highlighter then
      return {}
    end

    local contains = function(node, cursor)
      local row_s, col_s, row_e, col_e = node:range()
      local contains = true
      contains = contains and (row_s < cursor[1] or (row_s == cursor[1] and col_s <= cursor[2]))
      contains = contains and (cursor[1] < row_e or (row_e == cursor[1] and cursor[2] < col_e))
      return contains
    end

    local names = {}
    highlighter.tree:for_each_tree(function(tstree, ltree)
      if not tstree then
        return
      end

      local root = tstree:root()
      if contains(root, cursor) then
        local query = highlighter:get_query(ltree:lang()):query()
        for id, node in query:iter_captures(root, bufnr, cursor[1], cursor[1] + 1) do
          if contains(node, cursor) then
            local name = vim.treesitter.highlighter.hl_map[query.captures[id]]
            if name then
              table.insert(names, name)
            end
          end
        end
      end
    end)
    return names
  end
EOF

