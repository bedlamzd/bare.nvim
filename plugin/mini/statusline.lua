local enabled = true

if not enabled then return end

vim.pack.add { 'https://github.com/nvim-mini/mini.nvim' }

local sl = require 'mini.statusline'
sl.setup { use_icons = vim.g.have_nerd_font }
-- TODO: add snippet-active to statusline, with highlight
--  this it because exit from snippet is crap on luasnip
sl.section_location = function() return '%2l:%-2v' end
