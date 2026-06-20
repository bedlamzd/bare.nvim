local enabled = true

if not enabled then return end

pack_install_hook('nvim-dbee', function(data)
  local name, kind = data.spec.name, data.kind
  if not (kind == 'install' or kind == 'update') then return end
  if not data.active then vim.cmd.packadd 'nvim-dbee' end
  require('dbee').install()
end)

--- WARN: nui must be done on it's own, otherwise it's not available
--- during dbee install hook
vim.pack.add { 'https://github.com/MunifTanjim/nui.nvim' }
vim.pack.add {
  'https://github.com/kndndrj/nvim-dbee',
  'https://github.com/MattiasMTS/cmp-dbee',
  -- blink and blink.compat are needed for completion but keep them optional
}

require('dbee').setup {
  editor = {
    buffer_options = {
      filetype = 'sql.dbee',
    },
  },
}

vim.api.nvim_create_autocmd('FileType', {
  callback = function()
    local has_blink, blink = pcall(require, 'blink.cmp')

    if not has_blink then return end

    blink.add_source_provider('dbee', {
      name = 'cmp-dbee',
      module = 'blink.compat.source',
    })
    blink.add_filetype_source('dbee', 'dbee')

    require('cmp-dbee').setup()
  end,
  once = true,
  desc = 'Initialize cmp-dbee',
})
