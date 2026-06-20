local enabled = true

if not enabled then return end

vim.pack.add { 'https://github.com/rcarriga/nvim-notify' }

local nf = require 'notify'
vim.notify = nf.notify
