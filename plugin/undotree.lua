local enabled = true

if not enabled then return end

-- vim.cmd.packadd 'nvim.undotree'

vim.pack.add { 'https://github.com/XXiaoA/atone.nvim' }

require('atone').setup()

-- vim.pack.add{ 'https://github.com/mbbill/undotree' }
--
-- vim.g.undotree_WindowLayout = 4
-- vim.g.undotree_TreeVertShape = '│'
-- vim.g.undotree_TreeSplitShape = '─╯'
-- vim.g.undotree_TreeNodeShape = '●'
-- vim.g.undotree_TreeReturnShape = '─╮'
