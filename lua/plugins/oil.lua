---@module "lazy"
---@type LazyPluginSpec
return {
  'stevearc/oil.nvim',
  ---@module 'oil'
  ---@type oil.SetupOpts
  opts = {
    view_options = {
      show_hidden = true,
    },
    preview_win = {
      preview_method = 'load',
    },
    keymaps = {
      ['\\'] = { 'actions.close', mode = 'n' },
    },
  },
  cmd = 'Oil',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  lazy = false,
  keys = {
    { '\\', ':Oil<CR>', desc = 'Oil file explorer' },
  },
}
