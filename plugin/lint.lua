local enabled = true

if not enabled then return end

vim.pack.add { 'https://github.com/mfussenegger/nvim-lint' }

vim.api.nvim_create_autocmd({ 'BufReadPre', 'BufNewFile' }, {
  callback = function()
    local lint = require 'lint'
    lint.linters_by_ft = {
      sql = { 'sqlfluff' },
    }

    local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
    vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
      group = lint_augroup,
      callback = function()
        -- Only run the linter in modifiable buffers in order to avoid noise
        if vim.bo.modifiable then lint.try_lint() end
      end,
    })
  end,
  once = true,
})
