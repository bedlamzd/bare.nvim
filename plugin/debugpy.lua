local enabled = true

if not enabled then return end

vim.pack.add { 'https://github.com/mfussenegger/nvim-dap-python' }

vim.api.nvim_create_autocmd('FileType', {
  callback = function()
    local installed, plugin = pcall(vim.pack.get, { 'mason-nvim-dap.nvim' })

    if not (installed and plugin[1].active) then return end

    require('dap-python').setup(vim.fn.expand '$MASON/packages/debugpy/venv/bin/python')
  end,
  once = true,
  desc = 'Initialize nvim-dap-python',
  pattern = 'python',
})
