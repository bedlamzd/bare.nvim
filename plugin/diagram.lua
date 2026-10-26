local enabled = true

if not enabled then return end

vim.pack.add { 'https://github.com/3rd/diagram.nvim' }

vim.api.nvim_create_autocmd('VimEnter', {
  callback = function()
    require('diagram').setup {
      integrations = { require 'diagram.integrations.markdown' },
    }
  end,
  once = true,
  desc = 'Initialize 3rd/diagram',
})
