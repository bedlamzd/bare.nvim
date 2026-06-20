local enabled = true

if not enabled then return end

vim.pack.add {
  {
    src = 'https://github.com/chomosuke/typst-preview.nvim',
    version = vim.version.range '1.*',
  },
}

vim.api.nvim_create_autocmd('FileType', {
  callback = function()
    require('typst-preview.nvim').setup {
      dependencies_bin = {
        ['tinymist'] = 'tinymist',
      },
    }
  end,
  once = true,
  desc = 'Initialize typst-preview',
  pattern = 'typst',
})
