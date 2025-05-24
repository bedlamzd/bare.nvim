return {
  'rcarriga/nvim-notify',
  config = function(opts)
    local notify = require 'notify'
    notify.setup(opts)
    vim.notify = notify.notify
  end,
}
