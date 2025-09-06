---@module 'lazy'
---@type LazyPluginSpec
return {
  '3rd/diagram.nvim',
  dependencies = {
    '3rd/image.nvim',
  },
  opts = {
    events = {
      -- render manually only, because of zellij
      render_buffer = {},
      clear_buffer = { 'BufLeave' },
    },
  },
  keys = {
    {
      '<leader>pi',
      function()
        require('diagram').show_diagram_hover()
      end,
      mode = 'n',
      ft = { 'markdown' },
      desc = 'Show diagram in new tab',
    },
  },
}
