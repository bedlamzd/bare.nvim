local enabled = true

if not enabled then return end

pack_install_hook('LuaSnip', function(data)
  local name, kind = data.spec.name, data.kind
  if not (kind == 'install' or kind == 'update') then return end

  if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then return end

  vim.system({ 'make', 'install_jsregexp' }, { cwd = data.path })
end)

vim.pack.add {
  {
    src = 'https://github.com/saghen/blink.cmp',
    version = vim.version.range '1.*',
  },
  {
    src = 'https://github.com/saghen/blink.compat',
    version = vim.version.range '2.*',
  },
  {

    src = 'https://github.com/L3MON4D3/LuaSnip',
    version = vim.version.range '2.*',
  },
  'https://github.com/disrupted/blink-cmp-conventional-commits',
}
local ls = require 'luasnip'
ls.setup {
  -- TODO: consider adding checks on snippet region exit, so that snippet
  -- doesn't linger after I've moved on
  update_events = 'TextChanged,TextChangedI',
}
require('blink.compat').setup {}
require('blink.cmp').setup {
  keymap = {
    preset = 'default',
  },
  appearance = {
    nerd_font_variant = 'normal',
  },
  completion = {
    documentation = { auto_show = false, auto_show_delay_ms = 500 },
  },
  sources = {
    default = { 'lsp', 'snippets', 'buffer', 'path' },
    per_filetype = {
      gitcommit = { 'commits', inherit_defaults = true },
    },
    providers = {
      path = {
        opts = {
          show_hidden_files_by_default = true,
          get_cwd = function(_) return vim.fn.getcwd() end,
        },
      },
      cmdline = {
        -- WARN: There's an issue that on WSL path has windows part
        --  which messes with blink. So on WSL I disabled command completion
        enabled = vim.fn.has 'wsl' and function() return vim.fn.getcmdline():sub(1, 1) ~= '!' end
          or true,
      },
      commits = {
        name = 'Conventional Commits',
        module = 'blink-cmp-conventional-commits',
        opts = {},
      },
    },
  },
  snippets = { preset = 'luasnip' },
  fuzzy = { implementation = 'prefer_rust_with_warning' },
  signature = { enabled = true },
}

require('luasnip.loaders.from_lua').load()

-- TODO: consider adding normal mode
vim.keymap.set({ 'i' }, '<C-K>', function() ls.activate() end, { silent = true })
vim.keymap.set({ 'i', 's' }, '<C-L>', function() ls.jump(1) end, { silent = true })
vim.keymap.set({ 'i', 's' }, '<C-J>', function() ls.jump(-1) end, { silent = true })
vim.keymap.set({ 'i', 's' }, '<C-E>', function()
  if ls.choice_active() then ls.change_choice(1) end
end, { silent = true })
