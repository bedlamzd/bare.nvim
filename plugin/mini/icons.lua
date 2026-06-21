local enabled = true and vim.g.have_nerd_font

if not enabled then return end

vim.pack.add { 'https://github.com/nvim-mini/mini.nvim' }

require('mini.icons').setup()
-- Used for backwards compatibility with plugins that require `nvim-web-devicons` (e.g. telescope.nvim)
MiniIcons.mock_nvim_web_devicons()
