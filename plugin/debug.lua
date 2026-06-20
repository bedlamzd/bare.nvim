local enabled = true

if not enabled then return end

vim.pack.add {
  'https://github.com/mfussenegger/nvim-dap',
  'https://github.com/rcarriga/nvim-dap-ui',
  'https://github.com/nvim-neotest/nvim-nio',
}

local ui = setmetatable({ is_loaded = false }, {
  __index = function(t, k)
    if not t.is_loaded then
      require('dapui').setup()
      t.is_loaded = true
    end
    return require('dapui')[k]
  end,
})

local dap = setmetatable({ is_loaded = false }, {
  __index = function(t, k)
    if not t.is_loaded then
      local d = require 'dap'
      d.listeners.after.event_initialized['dapui_config'] = ui.open
      d.listeners.before.event_terminated['dapui_config'] = ui.close
      d.listeners.before.event_exited['dapui_config'] = ui.close
      t.is_loaded = true
    end
    return require('dap')[k]
  end,
})

local set = vim.keymap.set

set('n', '<F5>', function() dap.continue() end, { desc = 'Debug: Start/Continue' })
set('n', '<F1>', function() dap.step_into() end, { desc = 'Debug: Step Into' })
set('n', '<F2>', function() dap.step_over() end, { desc = 'Debug: Step Over' })
set('n', '<F3>', function() dap.step_out() end, { desc = 'Debug: Step Out' })
set('n', '<leader>b', function() dap.toggle_breakpoint() end, { desc = 'Debug: Toggle Breakpoint' })
set(
  'n',
  '<leader>B',
  function() dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ') end,
  { desc = 'Debug: Set Breakpoint' }
)
-- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
set('n', '<F7>', function() ui.toggle() end, { desc = 'Debug: See last session result.' })
