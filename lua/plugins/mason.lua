---@module 'lazy'
---@type LazyPluginSpec
return {
  'mason-org/mason.nvim',
  ---@module 'mason.settings'
  ---@type MasonSettings
  ---@diagnostic disable-next-line: missing-fields
  opts = {
    registries = {
      'file:' .. vim.fn.stdpath 'config' .. '/mason-registry-override',
      'github:mason-org/mason-registry',
    },
  },
}
