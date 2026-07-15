local enabled = true

if not enabled then return end

vim.pack.add { 'https://github.com/jmbuhr/otter.nvim' }

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'toml.mise' },
  callback = function() require('otter').activate() end,
})
