---@return fun(): [string, string]? schemas_iterator Over pairs of (schema_path, glob_pattern)
local k8s_schemas = function()
  local schemas_dir = vim.fs.abspath(vim.fn.stdpath 'data' .. '/../k8s-schemas')
  schemas_dir = vim.fs.normalize(schemas_dir)
  if not vim.fn.isdirectory(schemas_dir) then
    -- empty iterator
    return function() end
  end
  local schemas = vim.fs.dir(schemas_dir, { depth = 1 })

  return coroutine.wrap(function()
    for name, type in schemas do
      if type ~= 'file' or name == '_definitions.json' then goto continue end
      local pattern = string.gsub(vim.fs.basename(name), '^(.*)%.json', '%1.yaml')
      coroutine.yield { vim.fs.joinpath(schemas_dir, name), pattern }
      ::continue::
    end
  end)
end

-- LSP servers and clients are able to communicate to each other what features they support.
--  By default, Neovim doesn't support everything that is in the LSP specification.
--  When you add blink.cmp, luasnip, etc. Neovim now has *more* capabilities.
--  So, we create new capabilities with blink.cmp, and then broadcast that to the servers.
---@return lsp.ClientCapabilities
local get_lsp_capabilities = function()
  local capabilities = require('blink.cmp').get_lsp_capabilities()
  -- TODO: since this is unused + neovim 0.11 has folding range builtin
  --  ufo part has to be adapted somehow
  local is_ufo_enabled = require('lazy.core.config').plugins['nvim-ufo'] ~= nil
  if is_ufo_enabled then capabilities.textDocument.foldingRange = {
    dynamicRegistration = false,
    lineFoldingOnly = true,
  } end
  return capabilities
end

---@type table<string, table<> | fun(): table>
local servers = {
  basedpyright = {
    settings = {
      basedpyright = {
        disableOrganizeImports = true,
        analysis = {
          diagnosticMode = 'workspace',
        },
      },
    },
  },
  lua_ls = {
    on_init = function(client)
      if client.workspace_folders then
        local path = client.workspace_folders[1].name
        if path ~= vim.fn.stdpath 'config' and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc')) then return end
      end

      client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
        runtime = {
          version = 'LuaJIT',
          path = { 'lua/?.lua', 'lua/?/init.lua' },
        },
        workspace = {
          checkThirdParty = false,
          library = {
            vim.env.VIMRUNTIME,
            '${3rd}/luv/library',
            '${3rd}/busted/library',
          },
        },
      })
    end,
    settings = {
      Lua = {},
    },
  },
  docker_compose_language_service = nil,
  dockerls = nil,
  harper_ls = {
    settings = {
      ['harper-ls'] = {
        linters = { SentenceCapitalization = false },
      },
    },
  },
  yamlls = {
    -- NOTE: defer loading schemas until LS actually needed
    before_init = function(init_params, config)
      config.settings.yaml = vim.tbl_deep_extend('force', config.settings.yaml, {
        schemas = require('schemastore').yaml.schemas {
          extra = vim.iter(k8s_schemas()):fold({}, function(acc, v)
            schema_path, pattern = unpack(v)
            acc[#acc + 1] = {
              fileMatch = pattern,
              name = vim.fs.basename(schema_path),
              url = 'file://' .. schema_path,
            }
            return acc
          end),
        },
      })
    end,
    settings = {
      yaml = {
        -- WARN: kubernetes support will be removed eventually https://github.com/redhat-developer/yaml-language-server/issues/307
        -- NOTE: When names are not standard, a magic comment can be added
        --  see https://github.com/redhat-developer/yaml-language-server?tab=readme-ov-file#using-inlined-schema
        --  CRD lists
        --    - https://www.schemastore.org/
        --    - https://github.com/fluxcd-community/flux2-schemas
        --    - https://github.com/instrumenta/kubernetes-json-schema
        --    - https://github.com/datreeio/CRDs-catalog
        --  How to get used schemas from cluster
        --    - https://github.com/redhat-developer/yaml-language-server/issues/132#issuecomment-1403851309
        --    - https://github.com/datreeio/CRDs-catalog?tab=readme-ov-file#crd-extractor
        validate = true,
        schemaStore = { enable = false, url = '' },
      },
    },
  },
  jsonls = {
    -- NOTE: defer loading schemas until LS actually needed
    before_init = function(init_params, config)
      config.settings.json = vim.tbl_deep_extend('force', config.settings.json, {
        schemas = require('schemastore').json.schemas(),
      })
    end,
    settings = {
      json = {
        validate = true,
      },
    },
  },
  markdown_oxide = {
    workspace = {
      didChangeWatchedFiles = {
        dynamicRegistration = true,
      },
    },
  },
}

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
  callback = function(event)
    -- NOTE: Remember that Lua is a real programming language, and as such it is possible
    -- to define small helper and utility functions so you don't have to repeat yourself.
    --
    -- In this case, we create a function that lets us more easily define mappings specific
    -- for LSP related items. It sets the mode, buffer and description for us each time.
    local map = function(keys, func, desc, mode)
      mode = mode or 'n'
      vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
    end

    map('K', function(config)
      config = vim.tbl_extend('force', { border = 'single', wrap = false, relative = false }, config or {})
      vim.lsp.buf.hover(config)
    end, 'Hover')

    -- Rename the variable under your cursor.
    --  Most Language Servers support renaming across files, etc.
    map('grn', vim.lsp.buf.rename, '[R]e[n]ame')

    -- Execute a code action, usually your cursor needs to be on top of an error
    -- or a suggestion from your LSP for this to activate.
    map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })

    -- WARN: This is not Goto Definition, this is Goto Declaration.
    --  For example, in C this would take you to the header.
    map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

    -- The following two autocommands are used to highlight references of the
    -- word under your cursor when your cursor rests there for a little while.
    --    See `:help CursorHold` for information about when this is executed
    --
    -- When you move your cursor, the highlights will be cleared (the second autocommand).
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client:supports_method('textDocument/documentHighlight', event.buf) then
      local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
      vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.document_highlight,
      })

      vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.clear_references,
      })

      vim.api.nvim_create_autocmd('LspDetach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
        callback = function(event2)
          vim.lsp.buf.clear_references()
          vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
        end,
      })
    end
  end,
})

---@module 'lazy'
---@type LazySpec
return {
  'neovim/nvim-lspconfig',
  dependencies = {
    -- NOTE: config for mason is in dedicated file. here I merely state dependency
    'mason-org/mason.nvim',
    -- NOTE: Maps LSP server names between nvim-lspconfig and Mason package names.
    -- TODO: delete?
    'mason-org/mason-lspconfig.nvim',
    {
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      opts = {
        ensure_installed = vim.list_extend(vim.tbl_keys(servers or {}), {
          'stylua', -- Used to format Lua code
          'ruff',
          'jq',
          'yamlfmt',
          'cbfmt',
          'mdformat',
          'sqlfmt',
          'debugpy',
          'markdown-oxide',
        }),
      },
    },
    -- Useful status updates for LSP.
    { 'j-hui/fidget.nvim', opts = {} },
    -- NOTE: needed for yaml/json schema support in their lsp
    'b0o/schemastore.nvim',
  },
  config = function()
    for name, server in pairs(servers) do
      vim.lsp.config(name, server)
      vim.lsp.enable(name)
    end
  end,
  keys = {
    {
      '<leader>th',
      function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled()) end,
      desc = '[T]oggle Inlay [H]ints',
    },
  },
}
