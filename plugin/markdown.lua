local enabled = true

if not enabled then return end

pack_install_hook('markdown-preview.nvim', function(data)
  local name, kind = data.spec.name, data.kind
  if not (kind == 'install' or kind == 'update') then return end
  if not data.active then vim.cmd.packadd 'markdown-preview.nvim' end
  vim.fn['mkdp#util#install']()
end)

vim.pack.add {
  'https://github.com/iamcco/markdown-preview.nvim',
  'https://github.com/MeanderingProgrammer/render-markdown.nvim',
  'https://github.com/3rd/diagram.nvim',
}

vim.g.render_markdown_config = {
  completions = { lsp = { enabled = true } },
  win_options = { conceallevel = { rendered = 2 } },
}

local diagram_loaded = false

vim.api.nvim_create_autocmd('FileType', {
  callback = function(ev)
    if not diagram_loaded then
      diagram_loaded = true
      require('diagram').setup {
        events = {
          -- render manually only, because of zellij
          render_buffer = {},
          clear_buffer = { 'BufLeave' },
        },
      }
    end

    vim.keymap.set(
      'n',
      '<leader>pi',
      function() require('diagram').show_diagram_hover() end,
      { desc = 'Show diagram in new tab', buf = ev.buf }
    )

    vim.keymap.set(
      'n',
      '<leader>cp',
      '<Plug>MarkdownPreviewToggle',
      { desc = 'Markdown Preview', buf = ev.buf }
    )
  end,
  pattern = 'markdown',
  desc = 'Set markdown keymaps',
})
