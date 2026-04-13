; extends
; stolen from here https://github.com/zlkn/dotfiles/blob/0449b119f7b1ad145b94b0436b9bd7ee760f1fb4/vim/.config/nvim/queries/python/injections.scm

((comment) @injection.language
  (#gsub! @injection.language "#%s*language=%s*([%w%p]+)%s*" "%1")
  .
  (expression_statement
    (assignment
      right: (string
        (string_start)
        (string_content) @injection.content
        (string_end)))))

( (comment) @injection.language
  (#gsub! @injection.language "#%s*language=%s*([%w%p]+)%s*" "%1")
  .
  (expression_statement
    (assignment
      left: (identifier)
      right: (string
        (string_start)
        (string_content) @injection.content
        (string_end)))) )

