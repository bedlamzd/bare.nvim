--- @type vim.lsp.Config
return {
  workspace = {
    didChangeWatchedFiles = {
      dynamicRegistration = true,
    },
  },
}
