---@return fun(): [string, string]? schemas_iterator Over pairs of (schema_path, glob_pattern)
local k8s_schemas = function()
  local schemas_dir = vim.fs.abspath(vim.fn.stdpath 'data' .. '/../k8s-schemas')
  schemas_dir = vim.fs.normalize(schemas_dir)
  if not vim.fn.isdirectory(schemas_dir) then
    -- empty iterator
    return function() end
  end
  local schemas = vim.fs.dir(schemas_dir, { depth = 1 })

  return coroutine.wrap(function()
    for name, type in schemas do
      if type ~= 'file' or name == '_definitions.json' then goto continue end
      local pattern = string.gsub(vim.fs.basename(name), '^(.*)%.json', '%1.yaml')
      coroutine.yield { vim.fs.joinpath(schemas_dir, name), pattern }
      ::continue::
    end
  end)
end

--- @type vim.lsp.Config
return {
  -- NOTE: defer loading schemas until LS actually needed
  before_init = function(init_params, config)
    config.settings.yaml = vim.tbl_deep_extend('force', config.settings.yaml, {
      -- TODO: use pcall here, in case plugin is not installed
      schemas = require('schemastore').yaml.schemas {
        extra = vim.iter(k8s_schemas()):fold({}, function(acc, v)
          local schema_path, pattern = unpack(v)
          acc[#acc + 1] = {
            fileMatch = pattern,
            name = vim.fs.basename(schema_path),
            url = 'file://' .. schema_path,
          }
          return acc
        end),
      },
    })
  end,
  settings = {
    yaml = {
      -- WARN: kubernetes support will be removed eventually https://github.com/redhat-developer/yaml-language-server/issues/307
      -- NOTE: When names are not standard, a magic comment can be added
      --  see https://github.com/redhat-developer/yaml-language-server?tab=readme-ov-file#using-inlined-schema
      --  CRD lists
      --    - https://www.schemastore.org/
      --    - https://github.com/fluxcd-community/flux2-schemas
      --    - https://github.com/instrumenta/kubernetes-json-schema
      --    - https://github.com/datreeio/CRDs-catalog
      --  How to get used schemas from cluster
      --    - https://github.com/redhat-developer/yaml-language-server/issues/132#issuecomment-1403851309
      --    - https://github.com/datreeio/CRDs-catalog?tab=readme-ov-file#crd-extractor
      validate = true,
      schemaStore = { enable = false, url = '' },
    },
  },
}
