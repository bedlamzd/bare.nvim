-- stolen from here https://github.com/LazyVim/LazyVim/blob/5e7da4384d2ebd1a5f48119d0793f54a447f2db9/lua/lazyvim/plugins/extras/lang/markdown.lua#L74-L93
return {
  'iamcco/markdown-preview.nvim',
  cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },
  build = function()
    require('lazy').load { plugins = { 'markdown-preview.nvim' } }
    vim.fn['mkdp#util#install']()
  end,
  keys = {
    {
      '<leader>cp',
      ft = 'markdown',
      '<cmd>MarkdownPreviewToggle<cr>',
      desc = 'Markdown Preview',
    },
  },
  config = function()
    vim.cmd [[do FileType]]
  end,
}
