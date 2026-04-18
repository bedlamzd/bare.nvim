--- @type vim.lsp.Config
return {
  settings = {
    basedpyright = {
      disableOrganizeImports = true,
      analysis = {
        diagnosticMode = 'workspace',
      },
    },
  },
}
