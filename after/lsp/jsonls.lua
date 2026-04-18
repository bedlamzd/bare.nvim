--- @type vim.lsp.Config
return {
  -- NOTE: defer loading schemas until LS actually needed
  before_init = function(init_params, config)
    config.settings.json = vim.tbl_deep_extend('force', config.settings.json, {
      -- TODO: use pcall here, in case plugin is not installed
      schemas = require('schemastore').json.schemas(),
    })
  end,
  settings = {
    json = {
      validate = true,
    },
  },
}
