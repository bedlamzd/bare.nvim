---@param s string
---@return string
local function repo(s)
  local name = vim.split(s or '', '/', {
    plain = true,
    trimempty = true,
  })
  return ((name[#name] or ''):gsub('[\'"]', ''))
end

local function hook(idx, ref, opts)
  local node = ref and extras.dynamic_lambda(1, l._1, ref) or i(1, 'plugin')
  return sn(
    idx,
    fmt(
      [[
      pack_install_hook(
        '{}',
        function(data)
          local name, kind = data.spec.name, data.kind
          if not (kind == 'install' or kind == 'update') then return end
          vim.notify '"{}" plugin hook template not filled in properly!'
        end
      )
      ]],
      { node, extras.rep(1) }
    ),
    opts
  )
end

--- @module "luasnip"
--- @type LuaSnip.Snippet[]
return {
  s(
    'plug',
    fmt(
      [[
      local enabled = <enabled>

      if not enabled then return end

      <hook>vim.pack.add{ <source> }

      require('<repo>').setup {
      <opts>
      }
      ]],
      {
        enabled = c(1, { t 'true', t 'false' }),
        hook = c(4, {
          t '',
          sn(nil, { hook(1, k 'repo'), t { '', '', '' } }),
        }),
        source = sn(2, fmt("'{}'", { i(1, '', { key = 'source' }) })),
        repo = d(
          3,
          function(args) return sn(nil, i(1, repo(args[1][1]))) end,
          { k 'source' },
          { key = 'repo' }
        ),
        opts = i(5),
      },
      { delimiters = '<>' }
    )
  ),
  s('hook', hook(1)),
}
