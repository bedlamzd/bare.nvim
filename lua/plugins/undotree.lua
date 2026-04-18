return {
  'mbbill/undotree',
  init = function()
    vim.g.undotree_WindowLayout = 4
    vim.g.undotree_TreeVertShape = '│'
    vim.g.undotree_TreeSplitShape = '─╯'
    vim.g.undotree_TreeNodeShape = '●'
    vim.g.undotree_TreeReturnShape = '─╮'
  end,
}
