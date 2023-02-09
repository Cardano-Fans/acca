pub fn identity() -> fn(a) -> a {
  fn(x) { x }
}

test identity_1() {
  let fun = identity()

  fun(1) == 1
}
