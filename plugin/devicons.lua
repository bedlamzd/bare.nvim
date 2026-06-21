local enabled = true and vim.g.have_nerd_font

if not enabled then return end

vim.pack.add { 'https://github.com/nvim-tree/nvim-web-devicons' }

require('nvim-web-devicons').setup()
