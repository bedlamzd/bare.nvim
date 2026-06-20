local enabled = true

if not enabled then return end

vim.pack.add {
  'https://github.com/mason-org/mason.nvim',
  'https://github.com/mason-org/mason-lspconfig.nvim',
  'https://github.com/jay-babu/mason-nvim-dap.nvim',
  'https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim',
}

require('mason').setup {
  registries = {
    'file:' .. vim.fn.stdpath 'config' .. '/mason-registry-override',
    'github:mason-org/mason-registry',
  },
}

require('mason-lspconfig').setup {
  automatic_enable = false,
  ensure_installed = {},
}

require('mason-nvim-dap').setup {
  automatic_installation = false,
  ensure_installed = {},
}

require('mason-tool-installer').setup {
  ensure_installed = vim.iter(vim.tbl_values(vim.g.bedlamzd.tooling)):flatten():totable(),
}
