return {
  'nvim-treesitter/nvim-treesitter-context',
  opts = {
    max_lines = vim.o.scrolloff, -- this space isn't used anyway, so let's make it useful
    multiline_threshold = 2,
  },
}
