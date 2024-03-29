use aiken/builtin.{mod_integer}
use aiken/int

/// Returns a min of two elements.
///
/// ```aiken
/// amath.min(3, 9, int.compare) == 3
/// amath.min(-1, 5, int.compare) == -1
/// ```
pub fn min(left: a, right: a, compare: fn(a, a) -> Ordering) -> a {
  when compare(left, right) is {
    Greater ->
      right
    _ ->
      left
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

test min_3() {
  min(9, 9, int.compare) == 9
}

/// Returns a max of two elements.
///
/// ```aiken
/// amath.max(3, 9, int.compare) == 9
/// amath.max(-1, 5, int.compare) == 5
/// ```
pub fn max(left: a, right: a, compare: fn(a, a) -> Ordering) -> a {
  when compare(left, right) is {
    Greater ->
      left
    _ ->
      right
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

test max_3() {
  max(9, 9, int.compare) == 9
}

/// Computes greatest common divisor of two numbers
/// https://en.wikipedia.org/wiki/Greatest_common_divisor
///
/// ```aiken
/// amath.gcd(20, 15) == 5
/// amath.gcd(54, 24) == 6
/// ```
pub fn gcd(a: Int, b: Int) -> Int {
  when b is {
    0 ->
      a
    _n ->
      gcd(b, mod_integer(a, b))
  }
}

test gcd_0() {
  gcd(20, 15) == 5
}

test gcd_1() {
  gcd(54, 24) == 6
}
