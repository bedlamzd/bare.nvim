---@module 'lazy'
---@type LazySpec
return { -- Autoformat
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },
  keys = {
    {
      '<leader>f',
      function() require('conform').format { async = true } end,
      mode = '',
      desc = '[F]ormat buffer',
    },
  },
  ---@module 'conform'
  ---@type conform.setupOpts
  opts = {
    notify_on_error = false,
    format_on_save = function(bufnr)
      -- You can specify filetypes to autoformat on save here:
      local enabled_filetypes = {
        -- lua = true,
        -- python = true,
      }
      if enabled_filetypes[vim.bo[bufnr].filetype] then
        return { timeout_ms = 500 }
      else
        return nil
      end
    end,
    default_format_opts = { lsp_format = 'fallback' },
    formatters_by_ft = {
      -- Conform can also run multiple formatters sequentially
      python = { 'injected', 'ruff_fix', 'ruff_format', 'ruff_organize_imports' },
      yaml = { 'injected', 'yamlfmt' },
      sql = { 'sqlfmt' },
      markdown = { 'injected', 'mdformat' },
      json = { 'jq' },
      jsonc = { 'jq' },
      toml = { 'tombi' },
      --
      -- You can use 'stop_after_first' to run the first available formatter from the list
      javascript = { 'biome', 'prettierd', 'prettier', stop_after_first = true },
    },
  },
}
