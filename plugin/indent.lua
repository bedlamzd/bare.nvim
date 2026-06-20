local enabled = true

if not enabled then return end

vim.pack.add { 'https://github.com/NMAC427/guess-indent.nvim' }

require('guess-indent').setup {}
