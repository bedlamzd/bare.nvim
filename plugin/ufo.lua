local enabled = true

if not enabled then return end

vim.pack.add {
  'https://github.com/kevinhwang91/nvim-ufo',
  'https://github.com/kevinhwang91/promise-async',
}

vim.opt.foldcolumn = '1'
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.foldenable = true

-- Stolen from examples here https://github.com/kevinhwang91/nvim-ufo/blob/d31e2a9fd572a25a4d5011776677223a8ccb7e35/doc/example.lua#L26-L57
local ft_fold_provider = {}
local ufo = require 'ufo'

---@param bufnr number
---@return Promise
-- LSP -> treesitter -> indent
local function customizeSelector(bufnr)
  local function handleFallbackException(err, providerName)
    if type(err) == 'string' and err:match 'UfoFallbackException' then
      return ufo.getFolds(bufnr, providerName)
    else
      return require('promise').reject(err)
    end
  end

  return ufo
    .getFolds(bufnr, 'lsp')
    :catch(function(err) return handleFallbackException(err, 'treesitter') end)
    :catch(function(err) return handleFallbackException(err, 'indent') end)
end

ufo.setup {
  provider_selector = function(bufnr, filetype, buftype)
    return ft_fold_provider[filetype] or customizeSelector
  end,
}

vim.keymap.set('n', 'zR', ufo.openAllFolds, { desc = 'Open all folds' })
vim.keymap.set('n', 'zM', ufo.closeAllFolds, { desc = 'Close all folds' })
vim.keymap.set('n', '<leader>pf', ufo.peekFoldedLinesUnderCursor, { desc = '[P]eek [f]old' })

-- NOTE: mimic this <https://github.com/kevinhwang91/nvim-ufo/blob/ab3eb124062422d276fae49e0dd63b3ad1062cfc/README.md?plain=1#L80-L95>
--  although not sure if that's really needed since 0.11
vim.lsp.config('*', {
  before_init = function(init_params, config)
    config.capabilities.textDocument.foldingRange =
      vim.tbl_deep_extend('force', config.capabilities.textDocument.foldingRange, {
        dynamicRegistration = false,
        lineFoldingOnly = true,
      })
  end,
  capabilities = {
    textDocument = {
      foldingRange = {},
    },
  },
})
