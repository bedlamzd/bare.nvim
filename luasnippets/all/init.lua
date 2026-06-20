local function forge(domain) return sn(nil, fmt('https://' .. domain .. '/{}', { r(1, 'repo') })) end

return {
  s(
    'git',
    c(1, {
      forge 'github.com',
      forge 'codeberg.org',
      forge 'git.bedlamzd.dev',
    })
  ),
}
