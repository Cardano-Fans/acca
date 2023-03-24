use aiken/int

/// Returns a min of two elements.
///
/// ```aiken
/// amath.min(3, 9, int.compare) == 3
/// amath.min(-1, 5, int.compare) == -1
/// ```
pub fn min(left: a, right: a, compare: fn(a, a) -> Ordering) -> a {
  when compare(left, right) is {
    Greater -> right
    _ -> left
  }
}

test min_0() {
  min(-1, 0, int.compare) == -1
}

test min_1() {
  min(0, 9, int.compare) == 0
}

test min_2() {
  min(9, 1, int.compare) == 1
}

/// Returns a max of two elements.
///
/// ```aiken
/// amath.max(3, 9, int.compare) == 9
/// amath.max(-1, 5, int.compare) == 5
/// ```
pub fn max(left: a, right: a, compare: fn(a, a) -> Ordering) -> a {
  when compare(left, right) is {
    Greater -> left
    _ -> right
  }
}

test max_0() {
  max(-1, 0, int.compare) == 0
}

test max_1() {
  max(0, 1, int.compare) == 1
}

test max_2() {
  max(9, 1, int.compare) == 9
}
