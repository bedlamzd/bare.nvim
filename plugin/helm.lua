local enabled = true

if not enabled then return end

vim.pack.add { 'https://github.com/qvalentin/helm-ls.nvim' }

vim.api.nvim_create_autocmd('FileType', {
  callback = function() require('helm-ls').setup() end,
  pattern = 'helm',
  once = true,
  desc = 'Initialize helm-ls',
})
