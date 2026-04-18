--- @type vim.lsp.Config
return {
  filetypes = { 'sh', 'zsh', 'bash' },
  settings = {
    bashIde = {
      explainshellEndpoint = 'https://explainshell.com/',
    },
  },
}
