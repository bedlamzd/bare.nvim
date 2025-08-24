;extends
(if_statement
    condition: (_)@fold
    consequence: (_)@fold
    alternative: _
)
(if_statement
    alternative: [
      _ body:_
      _ consequence: _
      ]@fold
)
( type_parameter )@fold
( subscript )@fold
