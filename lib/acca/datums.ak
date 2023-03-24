use aiken/transaction.{InlineDatum, Output}

pub fn is_inline_datum(o: Output) {
  when o.datum is {
    InlineDatum(_) ->
      True
    _ ->
      False
  }
}
