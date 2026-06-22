local enabled = true

if not enabled then return end

vim.pack.add { 'https://github.com/stevearc/conform.nvim' }

local conform = require 'conform'
conform.setup {
  notify_on_error = true,
  formatters = {
    sqlfluff = {
      require_cwd = false,
      exit_codes = { 0, 1 },
    },
  },
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
    d2 = { 'injected', 'd2' },
    javascript = { 'biome', 'prettierd', 'prettier', stop_after_first = true },
    json = { 'jq' },
    jsonc = { 'jq' },
    kdl = { 'kdlfmt' },
    markdown = { 'injected', 'mdformat' },
    python = { 'injected', 'ruff_fix', 'ruff_format', 'ruff_organize_imports' },
    sql = { 'sqlfluff' },
    toml = { 'tombi' },
    yaml = { 'injected', 'yamlfmt' },
  },
}

vim.keymap.set(
  'n',
  '<leader>f',
  function() conform.format { async = true } end,
  { desc = '[F]ormat buffer' }
)
