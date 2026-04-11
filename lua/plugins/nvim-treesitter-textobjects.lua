local ts_move = function() return require 'nvim-treesitter-textobjects.move' end
local ts_select = function() return require 'nvim-treesitter-textobjects.select' end
-- local ts_interop = function() return require 'nvim-treesitter.textobjects.lsp_interop' end

---@module 'lazy'
---@type LazySpec
return {
  'nvim-treesitter/nvim-treesitter-textobjects',
  branch = 'main',
  init = function()
    -- Disable entire built-in ftplugin mappings to avoid conflicts.
    -- See https://github.com/neovim/neovim/tree/master/runtime/ftplugin for built-in ftplugins.
    vim.g.no_plugin_maps = true

    -- Or, disable per filetype (add as you like)
    -- vim.g.no_python_maps = true
    -- vim.g.no_ruby_maps = true
    -- vim.g.no_rust_maps = true
    -- vim.g.no_go_maps = true
  end,
  opts = {
    {
      select = {
        -- Automatically jump forward to textobjects, similar to targets.vim
        lookahead = true,
      },
      move = {
        set_jumps = true, -- whether to set jumps in the jumplist
      },
      lsp_interop = {
        -- NOTE: I define my own keymaps in LSP sesction because I want to
        -- use different lsp method to get definition. But floating window
        -- options are global for plugin and defined here
        enable = true,
        floating_preview_opts = {
          border = 'single',
        },
      },
    },
  },
  keys = {
    -- NOTE: select
    { 'af', function() ts_select().select_textobject('@function.outer', 'textobjects') end, mode = { 'x', 'o' }, desc = 'Select [A]round [F]unciton' },
    { 'if', function() ts_select().select_textobject('@function.inner', 'textobjects') end, mode = { 'x', 'o' }, desc = 'Select [I]nside [F]unciton' },
    { 'ac', function() ts_select().select_textobject('@class.outer', 'textobjects') end, mode = { 'x', 'o' }, desc = 'Select [A]round [C]lass' },
    { 'ic', function() ts_select().select_textobject('@class.inner', 'textobjects') end, mode = { 'x', 'o' }, desc = 'Select [I]nside [C]lass' },
    -- NOTE: move
    { ']m', function() ts_move().goto_next_start('@function.outer', 'textobjects') end, mode = { 'n', 'x', 'o' }, desc = 'Next function start' },
    { ']]', function() ts_move().goto_next_start('@class.outer', 'textobjects') end, mode = { 'n', 'x', 'o' }, desc = 'Next class start' },
    { ']M', function() ts_move().goto_next_end('@function.outer', 'textobjects') end, mode = { 'n', 'x', 'o' }, desc = 'Next function end' },
    { '][', function() ts_move().goto_next_end('@class.outer', 'textobjects') end, mode = { 'n', 'x', 'o' }, desc = 'Next class end' },
    { '[m', function() ts_move().goto_previous_start('@function.outer', 'textobjects') end, mode = { 'n', 'x', 'o' }, desc = 'Previous function start' },
    { '[[', function() ts_move().goto_previous_start('@class.outer', 'textobjects') end, mode = { 'n', 'x', 'o' }, desc = 'Previous class start' },
    { '[M', function() ts_move().goto_previous_end('@function.outer', 'textobjects') end, mode = { 'n', 'x', 'o' }, desc = 'Previous function end' },
    { '[]', function() ts_move().goto_previous_end('@class.outer', 'textobjects') end, mode = { 'n', 'x', 'o' }, desc = 'Previous class end' },
    -- NOTE: lsp_interop no longer supported by tree-sitter
    -- try to extract it?
    -- {
    --   -- For a given variable, will peek its definition
    --   '<leader>pd',
    --   function() ts_interop.peek_definition_code('@block.outer', 'textobjects', vim.lsp.protocol.Methods.textDocument_definition) end,
    --   desc = '[P]eek [D]efinition',
    -- },
    -- {
    --   -- For a given variable, will peek its type, if available, or its definition
    --   -- (though depends on server I guess) doesn't work with vaiables
    --   -- referencing functions (basedpyright at least), though. Seems like
    --   -- they have type (hover shows signature), but are missing where it's
    --   -- defined - typeDefinition returns nothing for them
    --   '<leader>pt',
    --   function() ts_interop.peek_definition_code('@block.outer', 'textobjects', vim.lsp.protocol.Methods.textDocument_typeDefinition) end,
    --   desc = '[P]eek [T]ype definition',
    -- },
  },
}
