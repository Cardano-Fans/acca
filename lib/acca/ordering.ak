use acca/string as astring
use aiken/int
use aiken/list
use aiken/option

/// Left biased resolution of comparing two orderings.
///
/// ```aiken
/// aordering.compare(Less, Greater) == Less
/// aordering.compare(Equal, Less) == Less
/// aordering.compare(Equal, Equal) == Equal
/// aordering.compare(Equal, Greather) == Greather
/// aordering.compare(Greather, Less) == Greather
/// ```
pub fn compare(left: Ordering, right: Ordering) -> Ordering {
  if left == Equal && right == Equal {
    Equal
  } else {
    if list.has([left, right], Less) {
      Less
    } else {
      Greater
    }
  }
}

/// Left biased resolution of comparing two orderings.
///
/// ```aiken
/// aordering.compare(Less, Greater) == Less
/// aordering.compare(Equal, Less) == Less
/// aordering.compare(Equal, Equal) == Equal
/// aordering.compare(Equal, Greather) == Greather
/// aordering.compare(Greather, Less) == Greather
/// ```
pub fn compare_option(
  left: Option<Ordering>,
  right: Option<Ordering>,
) -> Option<Ordering> {
  when (left, right) is {
    (Some(l), Some(r)) -> Some(compare(l, r))
    (Some(l), None) -> Some(l)
    (None, Some(r)) -> Some(r)
    _ -> None
  }
}

test compare_0() {
  compare(Less, Greater) == Less
}

test compare_1() {
  compare(Equal, Less) == Less
}

test compare_2() {
  compare(Equal, Equal) == Equal
}

test compare_3() {
  compare(Greater, Equal) == Greater
}

/// Reduces a List<Ordering> into one single Ordering.
/// Note that reduction is left biased.
///
/// ```aiken
/// aordering.reduce([]) == None
/// aordering.reduce([Less, Greater, Less]) == Some(Less)
/// aordering.reduce([Equal, Less, Greater]) == Some(Less)
/// aordering.reduce([Equal, Equal, Equal]) == Some(Equal)
/// aordering.reduce([Equal, Equal, Equal, Greater]) == Some(Greater)
/// ```
pub fn reduce(self: List<Ordering>) -> Option<Ordering> {
  when self is {
    [] -> None
    _ ->
      list.map(self, fn(elem) { Some(elem) })
        |> list.reduce(None, compare_option)
  }
}

test reduce_0() {
  reduce([]) == None
}

test reduce_1() {
  reduce([Less, Greater, Less]) == Some(Less)
}

test reduce_2() {
  reduce([Equal, Less, Greater]) == Some(Less)
}

test reduce_3() {
  reduce([Less, Greater, Greater]) == Some(Less)
}

test reduce_4() {
  reduce([Equal, Equal, Equal]) == Some(Equal)
}

test reduce_5() {
  reduce([Equal, Equal, Less]) == Some(Less)
}

test reduce_6() {
  reduce([Equal, Equal, Greater]) == Some(Greater)
}

test reduce_7() {
  reduce([Equal]) == Some(Equal)
}

test reduce_8() {
  reduce([Equal]) == Some(Equal)
}

/// Reduces a List<Ordering> into one single Ordering.
/// Note that reduction is left biased and function returns `Equal` for an empty list.
///
/// ```aiken
/// aordering.force_reduce([]) == Equal
/// aordering.force_reduce([Less, Greater, Less]) == Less
/// aordering.force_reduce([Equal, Less, Greater]) == Less
/// aordering.force_reduce([Equal, Equal, Equal]) == Equal
/// aordering.force_reduce([Equal, Equal, Equal, Greater]) == Greater
/// ```
pub fn force_reduce(self: List<Ordering>) -> Ordering {
  reduce(self)
    |> option.or_else(Equal)
}

test force_reduce_0() {
  force_reduce([]) == Equal
}

test force_reduce_1() {
  force_reduce([Less]) == Less
}

test force_reduce_2() {
  force_reduce([Greater, Less]) == Less
}

test force_reduce_3() {
  force_reduce([Greater, Equal]) == Greater
}

/// Compares two tuples with a given compare functions for both left and right side of the tuple.
///
/// ```aiken
/// aordering.compare_tuple((1, 2), (1, 2)) == Equal
/// aordering.compare_tuple((0, 1), (1, 2)) == Less
/// aordering.compare_tuple((2, 1), (1, 2)) == Greater
/// aordering.compare_tuple((1, @"a"), (1, @"a")) == Equal
/// aordering.compare_tuple((1, @"a"), (1, @"b")) == Less
/// ```
pub fn compare_tuple(
  left: (a, b),
  right: (a, b),
  first_compare: fn(a, a) -> Ordering,
  second_compare: fn(b, b) -> Ordering,
) -> Ordering {
  let (cp1, r1) = left
  let (cp2, r2) = right

  force_reduce([first_compare(cp1, cp2), second_compare(r1, r2)])
}

test compare_tuple_0() {
  compare_tuple((1, 2), (1, 2), int.compare, int.compare) == Equal
}

test compare_tuple_1() {
  compare_tuple((0, 2), (1, 2), int.compare, int.compare) == Less
}

test compare_tuple_2() {
  compare_tuple((2, 2), (1, 2), int.compare, int.compare) == Greater
}

test compare_tuple_3() {
  compare_tuple((1, @"a"), (1, @"a"), int.compare, astring.compare) == Equal
}

test compare_tuple_4() {
  compare_tuple((1, @"a"), (1, @"b"), int.compare, astring.compare) == Less
}

/// Compares two tuples with a given compare functions for both left and right side of the tuple.
/// This function will only look at left side of the tuple.
///
/// ```aiken
/// aordering.compare_tuple_left((1, 2), (1, 2)) == Equal
/// aordering.compare_tuple_left((0, 1), (1, 2)) == Less
/// aordering.compare_tuple_left((2, 1), (1, 2)) == Greater
/// aordering.compare_tuple_left((1, @"a"), (1, @"b")) == Equal
/// ```
pub fn compare_tuple_left(
  left: (a, b),
  right: (a, b),
  first_compare: fn(a, a) -> Ordering,
) -> Ordering {
  let (cp1, _r1) = left
  let (cp2, _r2) = right

  first_compare(cp1, cp2)
}

test compare_tuple_left_0() {
  compare_tuple_left((1, 2), (1, 2), int.compare) == Equal
}

test compare_tuple_left_1() {
  compare_tuple_left((0, 2), (1, 2), int.compare) == Less
}

test compare_tuple_left_2() {
  compare_tuple_left((2, 2), (1, 2), int.compare) == Greater
}

test compare_tuple_left_3() {
  compare_tuple_left((1, @"a"), (1, @"b"), int.compare) == Equal
}

/// Serialises ordering to string
/// ```aiken
/// aordering.to_string(Less) == @"Less"
/// aordering.to_string(Equal) == @"Equal"
/// aordering.to_string(Greater) == @"Greater"
/// ```
pub fn to_string(ord: Ordering) {
  when ord is {
    Less -> @"Less"
    Equal -> @"Equal"
    Greater -> @"Greater"
  }
}

test to_string_0() {
  to_string(Less) == @"Less"
}

test to_string_1() {
  to_string(Equal) == @"Equal"
}

test to_string_2() {
  to_string(Greater) == @"Greater"
}
