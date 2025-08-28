-- This function resolves a difference between neovim nightly (version 0.11) and stable (version 0.10)
---@param client vim.lsp.Client
---@param method vim.lsp.protocol.Method
---@param bufnr? integer some lsp support methods only in specific files
---@return boolean
local function client_supports_method(client, method, bufnr)
  if vim.fn.has 'nvim-0.11' == 1 then
    return client:supports_method(method, bufnr)
  else
    return client.supports_method(method, { bufnr = bufnr })
  end
end

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
      if type ~= 'file' or name == '_definitions.json' then
        goto continue
      end
      local pattern = string.gsub(vim.fs.basename(name), '^(.*)%.json', '%1.yaml')
      coroutine.yield { vim.fs.joinpath(schemas_dir, name), pattern }
      ::continue::
    end
  end)
end

---@type lsp.ClientCapabilities?
local _lsp_capabilities

-- LSP servers and clients are able to communicate to each other what features they support.
--  By default, Neovim doesn't support everything that is in the LSP specification.
--  When you add blink.cmp, luasnip, etc. Neovim now has *more* capabilities.
--  So, we create new capabilities with blink.cmp, and then broadcast that to the servers.
---@return lsp.ClientCapabilities
local get_lsp_capabilities = function()
  if _lsp_capabilities ~= nil then
    return _lsp_capabilities
  end
  local capabilities = require('blink.cmp').get_lsp_capabilities()
  local is_ufo_enabled = require('lazy.core.config').plugins['nvim-ufo'] ~= nil
  if is_ufo_enabled then
    capabilities.textDocument.foldingRange = {
      dynamicRegistration = false,
      lineFoldingOnly = true,
    }
  end
  _lsp_capabilities = capabilities
  return capabilities
end

local servers = {
  -- clangd = {},
  -- gopls = {},
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
  -- rust_analyzer = {},
  -- ... etc. See `:help lspconfig-all` for a list of all the pre-configured LSPs
  --
  -- Some languages (like typescript) have entire language plugins that can be useful:
  --    https://github.com/pmizio/typescript-tools.nvim
  --
  -- But for many setups, the LSP (`ts_ls`) will work just fine
  -- ts_ls = {},
  --

  lua_ls = {
    -- cmd = { ... },
    -- filetypes = { ... },
    -- capabilities = {},
    settings = {
      Lua = {
        completion = {
          callSnippet = 'Replace',
        },
        -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
        -- diagnostics = { disable = { 'missing-fields' } },
      },
    },
  },
  docker_compose_language_service = {},
  dockerls = {},
  harper_ls = {
    settings = {
      ['harper-ls'] = {
        linters = { SentenceCapitalization = false },
      },
    },
  },
  yamlls = {
    settings = {
      yaml = {
        -- WARN: kubernetes support will be removed eventually https://github.com/redhat-developer/yaml-language-server/issues/307
        -- NOTE: When names are not standard, a magic comment can be added
        --  see https://github.com/redhat-developer/yaml-language-server?tab=readme-ov-file#using-inlined-schema
        --  CRD lists
        --    - https://github.com/fluxcd-community/flux2-schemas
        --    - https://github.com/instrumenta/kubernetes-json-schema
        --  How to get used schemas from cluster
        --    - https://github.com/redhat-developer/yaml-language-server/issues/132#issuecomment-1403851309
        schemas = vim.iter(k8s_schemas()):fold({}, function(acc, v)
          acc[v[1]] = v[2]
          return acc
        end),
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

    -- Find references for the word under your cursor.
    map('grr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')

    -- Jump to the implementation of the word under your cursor.
    --  Useful when your language has ways of declaring types without an actual implementation.
    -- TODO: Make this global. This will shadow default "go to definition" and it's fine
    map('gri', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')

    -- Jump to the definition of the word under your cursor.
    --  This is where a variable was first declared, or where a function is defined, etc.
    --  To jump back, press <C-t>.
    map('grd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')

    -- WARN: This is not Goto Definition, this is Goto Declaration.
    --  For example, in C this would take you to the header.
    map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

    -- Fuzzy find all the symbols in your current document.
    --  Symbols are things like variables, functions, types, etc.
    map('gO', require('telescope.builtin').lsp_document_symbols, 'Open Document Symbols')

    -- Fuzzy find all the symbols in your current workspace.
    --  Similar to document symbols, except searches over your entire project.
    -- TODO: Make this global. If lsp is attached, I want to see symbols for it even if I'm in a buffer not related to this lsp
    -- TODO: If possible, detect workspace project before opening any file and enable this keymap
    -- TODO: Specialize by funcs, classes and variables
    map('gW', require('telescope.builtin').lsp_dynamic_workspace_symbols, 'Open Workspace Symbols')

    -- Jump to the type of the word under your cursor.
    --  Useful when you're not sure what type a variable is and you want to see
    --  the definition of its *type*, not where it was *defined*.
    -- TODO: Make this global. This will shadow default "go to definition" and it's fine
    map('grt', require('telescope.builtin').lsp_type_definitions, '[G]oto [T]ype Definition')

    -- The following two autocommands are used to highlight references of the
    -- word under your cursor when your cursor rests there for a little while.
    --    See `:help CursorHold` for information about when this is executed
    --
    -- When you move your cursor, the highlights will be cleared (the second autocommand).
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
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

    -- The following code creates a keymap to toggle inlay hints in your
    -- code, if the language server you are using supports them
    --
    -- This may be unwanted, since they displace some of your code
    -- TODO: No need to ask lsps if they support it. First of all this is either per buffer or global,
    --  so, cannot specify which lsp to turn it on for. Second, this won't error if lsp doesn't support it.
    --  This is just a setting on a bufffer, that's it
    -- TODO: Move to a separate keymap config
    if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
      map('<leader>th', function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
      end, '[T]oggle Inlay [H]ints')
    end
  end,
})

return {
  -- Main LSP Configuration
  'mason-org/mason-lspconfig.nvim',
  init = function()
    -- Diagnostic Config
    -- See :help vim.diagnostic.Opts
    vim.diagnostic.config {
      severity_sort = true,
      float = { border = 'rounded', source = 'if_many' },
      underline = { severity = vim.diagnostic.severity.ERROR },
      signs = vim.g.have_nerd_font and {
        text = {
          [vim.diagnostic.severity.ERROR] = '󰅚 ',
          [vim.diagnostic.severity.WARN] = '󰀪 ',
          [vim.diagnostic.severity.INFO] = '󰋽 ',
          [vim.diagnostic.severity.HINT] = '󰌶 ',
        },
      } or {},
      virtual_text = {
        source = 'if_many',
        spacing = 2,
        format = function(diagnostic)
          local diagnostic_message = {
            [vim.diagnostic.severity.ERROR] = diagnostic.message,
            [vim.diagnostic.severity.WARN] = diagnostic.message,
            [vim.diagnostic.severity.INFO] = diagnostic.message,
            [vim.diagnostic.severity.HINT] = diagnostic.message,
          }
          return diagnostic_message[diagnostic.severity]
        end,
      },
    }
  end,
  dependencies = {
    'mason-org/mason.nvim',
    'neovim/nvim-lspconfig',
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
    { 'j-hui/fidget.nvim', opts = {} },
    'saghen/blink.cmp',
  },
  event = 'VimEnter',
  opts = {
    ensure_installed = {}, -- explicitly set to an empty table (use mason-tool-installer)
    automatic_installation = false,
    handlers = {
      function(server_name)
        local server = servers[server_name] or {}
        -- This handles overriding only values explicitly passed
        -- by the server configuration above. Useful when disabling
        -- certain features of an LSP (for example, turning off formatting for ts_ls)
        server.capabilities = vim.tbl_deep_extend('force', {}, get_lsp_capabilities(), server.capabilities or {})
        require('lspconfig')[server_name].setup(server)
      end,
    },
  },
}
