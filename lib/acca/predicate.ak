pub fn not(predicate: fn(x) -> Bool) -> fn(x) -> Bool {
  fn(x) { !predicate(x) }
}
