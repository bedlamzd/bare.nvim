local pickers = require 'telescope.pickers'
local finders = require 'telescope.finders'
local conf = require('telescope.config').values
return {
  ruff = function(opts)
    opts = opts or {}
    pickers
      .new(opts, {
        prompt_title = 'ruff check',
        finder = finders.new_oneshot_job({ 'ruff', 'check', '--output-format=json-lines' }, {
          entry_maker = function(entry)
            local p = vim.fn.json_decode(entry)
            return {
              value = p,
              path = p['filename'],
              lnum = p['location']['row'],
              display = p['message'],
              ordinal = p['message'],
            }
          end,
        }),
        sorter = conf.generic_sorter(opts),
        previewer = conf.qflist_previewer(opts),
      })
      :find()
  end,
}
