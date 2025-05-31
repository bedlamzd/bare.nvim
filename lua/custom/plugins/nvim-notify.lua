---@type LazyPluginSpec
return {
  'rcarriga/nvim-notify',
  config = function(_, opts)
    local notify = require 'notify'
    notify.setup(opts)
    vim.notify = notify.notify
  end,
}
