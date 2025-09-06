---@module 'lazy'
---@type LazyPluginSpec
return {
  'mason-org/mason.nvim',
  ---@module 'mason'
  ---@type MasonSettings
  opts = {
    registries = {
      'file:' .. vim.fn.stdpath 'config' .. '/mason-registry-override',
      'github:mason-org/mason-registry',
    },
  },
}
