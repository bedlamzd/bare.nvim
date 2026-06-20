local enabled = true

if not enabled then return end

vim.pack.add {
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/folke/todo-comments.nvim',
}

require('todo-comments').setup { signs = false }
