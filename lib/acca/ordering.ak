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
    (Some(l), Some(r)) ->
      Some(compare(l, r))
    (Some(l), None) ->
      Some(l)
    (None, Some(r)) ->
      Some(r)
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
    [] ->
      None
    _ ->
      list.map(self, fn(elem) { Some(elem) })
        |> list.reduce(compare_option, None)
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
