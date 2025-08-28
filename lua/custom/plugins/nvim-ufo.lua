-- Stolen from examples here https://github.com/kevinhwang91/nvim-ufo/blob/d31e2a9fd572a25a4d5011776677223a8ccb7e35/doc/example.lua#L26-L57
local ft_fold_provider = {}

---@param bufnr number
---@return Promise
-- LSP -> treesitter -> indent
local function customizeSelector(bufnr)
  local function handleFallbackException(err, providerName)
    if type(err) == 'string' and err:match 'UfoFallbackException' then
      return require('ufo').getFolds(bufnr, providerName)
    else
      return require('promise').reject(err)
    end
  end

  return require('ufo')
    .getFolds(bufnr, 'lsp')
    :catch(function(err)
      return handleFallbackException(err, 'treesitter')
    end)
    :catch(function(err)
      return handleFallbackException(err, 'indent')
    end)
end

return {
  'kevinhwang91/nvim-ufo',
  dependencies = { 'kevinhwang91/promise-async' },
  init = function(_)
    vim.opt.foldcolumn = '1'
    vim.opt.foldlevel = 99
    vim.opt.foldlevelstart = 99
    vim.opt.foldenable = true
  end,
  event = 'BufEnter',
  opts = {
    provider_selector = function(bufnr, filetype, buftype)
      return ft_fold_provider[filetype] or customizeSelector
    end,
  },
  keys = {
    {
      'zR',
      function()
        require('ufo').openAllFolds()
      end,
    },
    {
      'zM',
      function()
        require('ufo').closeAllFolds()
      end,
    },
    {
      '<C-P>f',
      function()
        require('ufo').peekFoldedLinesUnderCursor()
      end,
      desc = '[P]eek [f]old',
    },
  },
}
