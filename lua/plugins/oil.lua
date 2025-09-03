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
  },
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  lazy = false,
  keys = {
    {
      '\\',
      function()
        require('oil').toggle_float()
      end,
      desc = 'Oil float',
    },
  },
}
