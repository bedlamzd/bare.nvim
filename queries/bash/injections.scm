; extends
; stolen from here https://github.com/zlkn/dotfiles/blob/e5131df532d9236975975da265d15a2debcacdbc/vim/.config/nvim/queries/bash/injections.scm

((comment) @injection.language
  (#gsub! @injection.language "#%s*language=%s*([%w%p]+)%s*" "%1")
 .
(redirected_statement
redirect: (heredoc_redirect
  (heredoc_start)
  (heredoc_body) @injection.content
  (heredoc_end))))
