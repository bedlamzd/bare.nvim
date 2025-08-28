return { -- Highlight, edit, and navigate code
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  main = 'nvim-treesitter.configs', -- Sets main module to use for opts
  -- [[ Configure Treesitter ]] See `:help nvim-treesitter`
  opts = {
    ensure_installed = { 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc', 'python' },
    -- Autoinstall languages that are not installed
    auto_install = true,
    highlight = {
      enable = true,
      -- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
      --  If you are experiencing weird indenting issues, add the language to
      --  the list of additional_vim_regex_highlighting and disabled languages for indent.
      additional_vim_regex_highlighting = { 'ruby' },
    },
    -- NOTE: See meta issue with current problems https://github.com/nvim-treesitter/nvim-treesitter/issues/7840
    indent = { enable = false, disable = { 'ruby' } },
    incremental_selection = { enable = true },
    textobjects = {
      select = {
        enable = true,

        -- Automatically jump forward to textobjects, similar to targets.vim
        lookahead = true,

        keymaps = {
          -- You can use the capture groups defined in textobjects.scm
          ['af'] = '@function.outer',
          ['if'] = '@function.inner',
          ['ac'] = '@class.outer',
          ['ic'] = '@class.inner',
        },
      },
      move = {
        enable = true,
        set_jumps = true, -- whether to set jumps in the jumplist
        goto_next_start = {
          [']m'] = '@function.outer',
          [']]'] = '@class.outer',
        },
        goto_next_end = {
          [']M'] = '@function.outer',
          [']['] = '@class.outer',
        },
        goto_previous_start = {
          ['[m'] = '@function.outer',
          ['[['] = '@class.outer',
        },
        goto_previous_end = {
          ['[M'] = '@function.outer',
          ['[]'] = '@class.outer',
        },
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
  -- There are additional nvim-treesitter modules that you can use to interact
  -- with nvim-treesitter. You should go explore a few and see what interests you:
  --
  --    - Incremental selection: Included, see `:help nvim-treesitter-incremental-selection-mod`
  --    - Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
  --    - Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
  keys = {
    {
      -- For a given variable, will peek its definition
      'gpd',
      function()
        local ts_interop = require 'nvim-treesitter.textobjects.lsp_interop'
        ts_interop.peek_definition_code('@block.outer', 'textobjects', vim.lsp.protocol.Methods.textDocument_definition)
      end,
      desc = '[P]eek [D]efinition',
    },
    {
      -- For a given variable, will peek its type, if available, or its definition
      -- (though depends on server I guess) doesn't work with vaiables
      -- referencing functions (basedpyright at least), though. Seems like
      -- they have type (hover shows signature), but are missing where it's
      -- defined - typeDefinition returns nothing for them
      'gpt',
      function()
        local ts_interop = require 'nvim-treesitter.textobjects.lsp_interop'
        ts_interop.peek_definition_code('@block.outer', 'textobjects', vim.lsp.protocol.Methods.textDocument_typeDefinition)
      end,
      desc = '[P]eek [T]ype definition',
    },
  },
}
