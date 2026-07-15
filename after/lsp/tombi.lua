--- @type vim.lsp.Config
return {
  filetypes = { 'toml', 'toml.mise' },
  on_attach = function(_, bufnr)
    local ft = vim.api.nvim_get_option_value('filetype', { buf = tonumber(bufnr) or 0 })
    if ft == nil or not vim.list_contains(vim.split(ft, '.', { plain = true }), 'mise') then return end
    -- NOTE: semantic tokens for some reason override injection highlights
    vim.lsp.semantic_tokens.enable(false, { bufnr = bufnr })
  end,
}
