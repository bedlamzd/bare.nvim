local enabled = true

if not enabled then return end

vim.pack.add { 'https://github.com/stevearc/oil.nvim' }

require('oil').setup {
  view_options = {
    show_hidden = true,
  },
  preview_win = {
    preview_method = 'load',
  },
  keymaps = {
    ['\\'] = { 'actions.close', mode = 'n' },
  },
}

vim.keymap.set('n', '\\', ':Oil<CR>', { desc = 'Oil file explorer' })
