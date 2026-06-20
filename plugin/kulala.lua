local enabled = true

if not enabled then return end

vim.pack.add { 'https://github.com/mistweaverco/kulala.nvim' }

vim.api.nvim_create_autocmd('FileType', {
  callback = function()
    require('kulala').setup {
      global_keymaps = true,
      global_keymaps_prefix = '<leader>R',
      kulala_keymaps_prefix = '',
    }
  end,
  pattern = { 'http', 'rest' },
  desc = 'Initialize kulala',
  once = true,
})
