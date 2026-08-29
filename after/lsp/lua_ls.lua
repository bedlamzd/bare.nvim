--- @type vim.lsp.Config
return {
  before_init = function(init_params, config)
    local wf = init_params.workspaceFolders
    if wf and wf ~= vim.NIL then
      local path = wf[1].name
      if
        path ~= vim.fn.stdpath 'config'
        and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc'))
      then
        return
      end
    end

    local settings = config.settings --[[@as lspconfig.settings.lua_ls]]
    settings.Lua = vim.tbl_deep_extend('force', config.settings.Lua, {
      runtime = {
        version = 'LuaJIT',
        path = { 'lua/?.lua', 'lua/?/init.lua' },
      },
      workspace = {
        checkThirdParty = false,
        library = { vim.env.VIMRUNTIME },
      },
    })
  end,
  on_init = function(client)
    -- Disable formatting (formatting is done by stylua)
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
    client.server_capabilities.documentOnTypeFormattingProvider = nil
  end,
  settings = {
    Lua = {
      format = {
        enable = false,
      },
    },
  },
}
