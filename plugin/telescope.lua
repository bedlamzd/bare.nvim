local enabled = true

if not enabled then return end

pack_install_hook('telescope-fzf-native.nvim', function(data)
  local name, kind = data.spec.name, data.kind
  if not (kind == 'install' or kind == 'update') then return end
  vim.system({ 'make' }, { cwd = data.path })
end)

vim.pack.add {
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/nvim-telescope/telescope-fzf-native.nvim',
  'https://github.com/nvim-telescope/telescope-ui-select.nvim',
  'https://github.com/nvim-telescope/telescope.nvim',
}

local ts = require 'telescope'

ts.setup {
  defaults = {
    vimgrep_arguments = {
      'rg',
      '--color=never',
      '--no-heading',
      '--with-filename',
      '--line-number',
      '--column',
      '--smart-case',
      '--multiline',
    },
    --   mappings = {
    --     i = { ['<c-enter>'] = 'to_fuzzy_refine' },
    --   },
  },
  -- pickers = {}
  extensions = {
    ['ui-select'] = { require('telescope.themes').get_dropdown() },
  },
}

pcall(ts.load_extension, 'fzf')
pcall(ts.load_extension, 'ui-select')

local builtin = require 'telescope.builtin'
vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set(
  'n',
  '<leader>sF',
  function()
    return builtin.find_files {
      hidden = true,
      no_ignore = true,
      no_ignore_parent = true,
    }
  end,
  { desc = '[S]earch [F]iles everywhere' }
)
vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
vim.keymap.set(
  { 'n', 'v' },
  '<leader>sw',
  builtin.grep_string,
  { desc = '[S]earch current [W]ord' }
)
vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set(
  'n',
  '<leader>sG',
  function()
    return builtin.live_grep {
      additional_args = {
        '-uu',
      },
    }
  end,
  { desc = '[S]earch by [G]rep everywhere' }
)
vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set(
  'n',
  '<leader>dd',
  function() return builtin.diagnostics { bufnr = 0 } end,
  { desc = '[S]earch this [d]ocument [d]iagnostics' }
)
vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
vim.keymap.set(
  'n',
  '<leader>s.',
  builtin.oldfiles,
  { desc = '[S]earch Recent Files ("." for repeat)' }
)
vim.keymap.set('n', '<leader>sc', builtin.commands, { desc = '[S]earch [C]ommands' })
vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('telescope-lsp-attach', { clear = true }),
  callback = function(event)
    local buf = event.buf

    -- Find references for the word under your cursor.
    vim.keymap.set(
      'n',
      'grr',
      builtin.lsp_references,
      { buffer = buf, desc = '[G]oto [R]eferences' }
    )

    -- Jump to the implementation of the word under your cursor.
    -- Useful when your language has ways of declaring types without an actual implementation.
    -- TODO: Make this global (i.e. not on LspAttach). This will shadow default "go to definition" and it's fine
    vim.keymap.set(
      'n',
      'gri',
      builtin.lsp_implementations,
      { buffer = buf, desc = '[G]oto [I]mplementation' }
    )

    -- Jump to the definition of the word under your cursor.
    -- This is where a variable was first declared, or where a function is defined, etc.
    -- To jump back, press <C-t>.
    vim.keymap.set(
      'n',
      'grd',
      builtin.lsp_definitions,
      { buffer = buf, desc = '[G]oto [D]efinition' }
    )

    -- Fuzzy find all the symbols in your current document.
    -- Symbols are things like variables, functions, types, etc.
    vim.keymap.set(
      'n',
      'gO',
      builtin.lsp_document_symbols,
      { buffer = buf, desc = 'Open Document Symbols' }
    )

    -- Fuzzy find all the symbols in your current workspace.
    -- Similar to document symbols, except searches over your entire project.
    -- TODO: Make this global. If lsp is attached, I want to see symbols for it even if I'm in a buffer not related to this lsp
    -- TODO: If possible, detect workspace project before opening any file and enable this keymap
    -- TODO: Specialize by funcs, classes and variables
    vim.keymap.set(
      'n',
      'gW',
      builtin.lsp_dynamic_workspace_symbols,
      { buffer = buf, desc = 'Open Workspace Symbols' }
    )

    -- Jump to the type of the word under your cursor.
    -- Useful when you're not sure what type a variable is and you want to see
    -- the definition of its *type*, not where it was *defined*.
    -- TODO: Make this global. This will shadow default "go to definition" and it's fine
    vim.keymap.set(
      'n',
      'grt',
      builtin.lsp_type_definitions,
      { buffer = buf, desc = '[G]oto [T]ype Definition' }
    )
  end,
})

-- Slightly advanced example of overriding default behavior and theme
vim.keymap.set('n', '<leader>/', function()
  -- You can pass additional configuration to Telescope to change the theme, layout, etc.
  builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false,
  })
end, { desc = '[/] Fuzzily search in current buffer' })

-- It's also possible to pass additional configuration options.
--  See `:help telescope.builtin.live_grep()` for information about particular keys
vim.keymap.set(
  'n',
  '<leader>s/',
  function()
    builtin.live_grep {
      grep_open_files = true,
      prompt_title = 'Live Grep in Open Files',
    }
  end,
  { desc = '[S]earch [/] in Open Files' }
)

-- Shortcut for searching your Neovim configuration files
vim.keymap.set(
  'n',
  '<leader>sn',
  function() builtin.find_files { cwd = vim.fn.stdpath 'config' } end,
  { desc = '[S]earch [N]eovim files' }
)
