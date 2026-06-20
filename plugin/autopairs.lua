local enabled = true

if not enabled then return end

vim.pack.add { 'https://github.com/windwp/nvim-autopairs' }

require('nvim-autopairs').setup {}
