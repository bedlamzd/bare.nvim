vim.filetype.add {
  filename = {
    ['compose.yaml'] = 'yaml.docker-compose',
    ['compose.yml'] = 'yaml.docker-compose',
    ['docker-compose.yml'] = 'yaml.docker-compose',
    ['docker-compose.yaml'] = 'yaml.docker-compose',
  },
  pattern = {
    ['%.?miserc%.toml'] = 'toml.mise',
    ['%.?mise%.toml'] = 'toml.mise',
    ['%.?mise%..-%.toml'] = 'toml.mise',
    ['%.?mise/config%.toml'] = 'toml.mise',
    ['%.?mise/config%..-%.toml'] = 'toml.mise',
    ['%.?mise/conf.d/.-%.toml'] = 'toml.mise',
  },
}
