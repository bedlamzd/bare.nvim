return {
  'mason-org/mason.nvim',
  opts = {
    registries = {
      'file:' .. vim.fn.stdpath 'config' .. '/mason-registry-override',
      'github:mason-org/mason-registry',
    },
  },
}
