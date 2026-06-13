---@module 'lazy'
---@type LazySpec
return {
  'kndndrj/nvim-dbee',
  dependencies = { 'MunifTanjim/nui.nvim' },
  build = function() require('dbee').install() end,
  opts = {},
  cmd = 'Dbee',
  specs = {
    'saghen/blink.compat',
    optional = true,
    specs = {
      'saghen/blink.cmp',
      optional = true,
      specs = {
        { 'MattiasMTS/cmp-dbee', opts = {}, lazy = true },
        {
          'kndndrj/nvim-dbee',
          dependencies = { 'MattiasMTS/cmp-dbee' },
        },
      },
      opts = {
        -- extend blink's config (merged by lazy)
        sources = {
          per_filetype = {
            sql = { 'dbee', 'buffer' },
          },
          providers = {
            dbee = {
              name = 'cmp-dbee',
              module = 'blink.compat.source',
            },
          },
        },
      },
    },
  },
}
