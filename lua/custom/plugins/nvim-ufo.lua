return {
  'kevinhwang91/nvim-ufo',
  dependencies = { 'kevinhwang91/promise-async' },
  init = function(_)
    vim.opt.foldcolumn = '1'
    vim.opt.foldlevel = 99
    vim.opt.foldlevelstart = 99
    vim.opt.foldenable = true
  end,
  event = 'BufEnter',
  keys = {
    {
      'zR',
      function()
        require('ufo').openAllFolds()
      end,
    },
    {
      'zM',
      function()
        require('ufo').closeAllFolds()
      end,
    },
  },
}
