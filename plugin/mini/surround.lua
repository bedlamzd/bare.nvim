local enabled = true

if not enabled then return end

vim.pack.add { 'https://github.com/nvim-mini/mini.nvim' }

require('mini.surround').setup()
