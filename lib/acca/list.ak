use acca/predicate.{not}
use aiken/builtin
use aiken/list.{
  at, concat, drop, filter, foldl, has, head, last, push, reverse, take, unique,
}
use aiken/math

fn do_reduce_left(self: List<a>, acc: a, with: fn(a, a) -> a) -> a {
  when self is {
    [] ->
      acc
    [h, ..t] ->
      do_reduce_left(t, with(acc, h), with)
  }
}

/// Reduce a list from left to right.
///
/// ```aiken
/// list.reduce_left([1, 2, 3], fn(n, total) { n + total }, 0) == 6
/// list.reduce_left(["1", "2", "3"], fn(a, b) { builtin.append_string(a, b), "0" } ) == "0123"
/// ```
pub fn reduce_left(self: List<a>, with: fn(a, a) -> a, zero: a) -> a {
  do_reduce_left(self, zero, with)
}

test reduce_left_1() {
  let chars =
    []

  let zero =
    @"0"

  let reducer =
    fn(a, b) { builtin.append_string(a, b) }

  @"0" == reduce_left(chars, reducer, zero)
}

test reduce_left_2() {
  let chars =
    [@"a", @"b", @"c", @"d"]

  let zero =
    @"0"

  let reducer =
    fn(a, b) { builtin.append_string(a, b) }

  @"0abcd" == reduce_left(chars, reducer, zero)
}

fn do_reduce_right(self: List<a>, acc: a, with: fn(a, a) -> a) -> a {
  when self is {
    [] ->
      acc
    [h, ..t] ->
      do_reduce_right(t, with(acc, h), with)
  }
}

/// Reduce a list from right to left.
///
/// ```aiken
/// list.reduce_right([1, 2, 3], fn(n, total) { n + total }, 0) == 6
/// list.reduce_right(["1", "2", "3"], fn(a, b) { builtin.append_string(a, b) },  "0" ) == "0321"
/// ```
pub fn reduce_right(self: List<a>, with: fn(a, a) -> a, zero: a) -> a {
  do_reduce_right(list.reverse(self), zero, with)
}

test reduce_right_1() {
  let chars =
    []

  let zero =
    @"0"

  let reducer =
    fn(a, b) { builtin.append_string(a, b) }

  @"0" == reduce_right(chars, reducer, zero)
}

test reduce_right_2() {
  let chars =
    [@"a", @"b", @"c", @"d"]

  let zero =
    @"0"

  let reducer =
    fn(a, b) { builtin.append_string(a, b) }

  @"0dcba" == reduce_right(chars, reducer, zero)
}

pub fn first(self: List<a>) -> Option<a> {
  head(self)
}

pub fn non_empty(self: List<a>) -> Bool {
  when self is {
    [] ->
      False
    _ ->
      True
  }
}

test non_empty_1() {
  non_empty([]) == False
}

test non_empty_2() {
  non_empty([1]) == True
}

pub fn prepend(self: List<a>, item: a) -> List<a> {
  push(self, item)
}

/// Appends an element to the end of the list
pub fn append(self: List<a>, item: a) -> List<a> {
  concat(self, [item])
}

test append_1() {
  append([], 1) == [1]
}

test append_2() {
  append([1, 2, 3], 4) == [1, 2, 3, 4]
}

fn do_take_until(
  tail: List<a>,
  accum: List<a>,
  predicate: fn(a) -> Bool,
) -> List<a> {
  when tail is {
    [] ->
      reverse(accum)
    [h, ..t] ->
      if predicate(h) {
        do_take_until(t, push(accum, h), predicate)
      } else {
        do_take_until([], accum, predicate)
      }
  }
}

pub fn take_until(self: List<a>, predicate: fn(a) -> Bool) -> List<a> {
  do_take_until(self, [], predicate)
}

test take_until_1() {
  take_until([], fn(x) { x > 0 }) == []
}

test take_until_2() {
  take_until([1, 2, 3, 4, 5], fn(x) { x <= 2 }) == [1, 2]
}

test take_until_3() {
  take_until([1, 2, 3, 4, 5], fn(x) { x < 4 }) == [1, 2, 3]
}

test take_until_4() {
  take_until([1, 2, 3, 4, 5], fn(x) { x != 4 }) == [1, 2, 3]
}

pub fn filter_not(self: List<a>, predicate: fn(a) -> Bool) -> List<a> {
  filter(self, not(predicate))
}

test filter_not_1() {
  filter_not([1, 2, 3], fn(x) { x == 1 }) == [2, 3]
}

// pub fn group_by(
//   self: List<a>,
//   predicate: fn(a) -> Bool,
// ) -> Dict<ByteArray, List<a>> {
//   let (l, r) = partition(self, predicate)

//   dict.new()
//   |> dict.insert(#"00", l)
//   |> dict.insert(#"01", r)
// }

// test group_by_1() {
//   let d: Dict<ByteArray, List<Int>> =
//     group_by([1, 2, 3, 4, 5], fn(x) { x <= 3 })

//   let l =
//     dict.get(d, #"00")
//     |> aoption.get()

//   let r =
//     dict.get(d, #"01")
//     |> aoption.get()

//   l == [1, 2, 3] && r == [4, 5]
// }

fn do_grouped(tail: List<a>, accum: List<List<a>>, n: Int) -> List<List<a>> {
  when tail is {
    [] ->
      accum
    all -> {
      let took =
        take(all, n)
      let rest =
        drop(all, n)
      do_grouped(rest, concat(accum, [took]), n)
    }
  }
}

pub fn grouped(self: List<a>, n: Int) -> List<List<a>> {
  if n <= 0 {
    []
  } else {
    do_grouped(self, [], n)
  }
}

test grouped_1() {
  grouped([], 2) == []
}

test grouped_2() {
  let items =
    grouped([1, 2, 3, 4, 5, 6], 2)
  expect Some(g1) =
    at(items, 0)
  expect Some(g2) =
    at(items, 1)
  expect Some(g3) =
    at(items, 2)

  g1 == [1, 2] && g2 == [3, 4] && g3 == [5, 6]
}

test grouped_3() {
  let items =
    grouped([1, 2, 3], 1)
  expect Some(g1) =
    at(items, 0)
  expect Some(g2) =
    at(items, 1)
  expect Some(g3) =
    at(items, 2)

  g1 == [1] && g2 == [2] && g3 == [3]
}

test grouped_4() {
  let items =
    grouped([1, 2, 3, 4, 5, 6], 3)
  expect Some(g1) =
    at(items, 0)
  expect Some(g2) =
    at(items, 1)

  g1 == [1, 2, 3] && g2 == [4, 5, 6]
}

test grouped_5() {
  [] == grouped([1, 2, 3, 4, 5, 6], 0)
}

test grouped_6() {
  [] == grouped([1, 2, 3, 4, 5, 6], -1)
}

pub fn bi_diff(self1: List<a>, self2: List<a>) -> List<a> {
  let diff1 =
    filter(self1, fn(x) { !has(self2, x) })
  let diff2 =
    filter(self2, fn(x) { !has(self1, x) })

  unique(concat(diff1, diff2))
}

test bi_diff_1() {
  bi_diff([1, 2], [1, 3]) == [2, 3]
}

test bi_diff_2() {
  bi_diff([1, 2, 3], [1, 2, 3]) == []
}

test bi_diff_3() {
  bi_diff([], []) == []
}

pub fn sliding(self: List<a>, n: Int) -> List<List<a>> {
  if n <= 1 {
    []
  } else {
    do_sliding(self, [], n)
  }
}

fn do_sliding(tail: List<a>, accum: List<List<a>>, n: Int) -> List<List<a>> {
  when tail is {
    [] ->
      accum
    [_] ->
      accum
    all -> {
      let took =
        take(all, n)
      let rest =
        drop(all, n)
      let l =
        last(took)
      when l is {
        Some(ll) ->
          do_sliding(push(rest, ll), concat(accum, [took]), n)
        _ ->
          do_sliding([], concat(accum, [took]), n)
      }
    }
  }
}

test sliding_1() {
  sliding([], 1) == []
}

test sliding_2() {
  sliding([], 0) == []
}

test sliding_3() {
  sliding([], 2) == []
}

test sliding_4() {
  let items =
    sliding([1, 2, 3], 2)
  expect Some(g1) =
    at(items, 0)
  expect Some(g2) =
    at(items, 1)

  g1 == [1, 2] && g2 == [2, 3]
}

test sliding_5() {
  let items =
    sliding([1, 2, 3, 4, 5], 2)
  expect Some(g1) =
    at(items, 0)
  expect Some(g2) =
    at(items, 1)
  expect Some(g3) =
    at(items, 2)
  expect Some(g4) =
    at(items, 3)

  g1 == [1, 2] && g2 == [2, 3] && g3 == [3, 4] && g4 == [4, 5]
}

test sliding_6() {
  let items =
    sliding([1, 2, 3, 4, 5, 6], 3)
  expect Some(g1) =
    at(items, 0)
  expect Some(g2) =
    at(items, 1)
  expect Some(g3) =
    at(items, 2)

  g1 == [1, 2, 3] && g2 == [3, 4, 5] && g3 == [5, 6]
}

test sliding_7() {
  let items =
    sliding([1, 2, 3, 4, 5], 3)
  expect Some(g1) =
    at(items, 0)
  expect Some(g2) =
    at(items, 1)

  g1 == [1, 2, 3] && g2 == [3, 4, 5]
}

test sliding_8() {
  sliding([1, 2, 3, 4, 5], 1) == []
}

fn indices(self: List<a>) -> List<Int> {
  when self is {
    [] ->
      []
    _ -> {
      let len =
        list.length(self)
      list.range(0, len - 1)
    }
  }
}

test indices_1() {
  indices([]) == []
}

test indices_2() {
  indices([1]) == [0]
}

test indices_3() {
  indices([1, 2, 3]) == [0, 1, 2]
}

fn do_index_of(tail: List<a>, item: a, acc: Int) -> Int {
  when tail is {
    [] ->
      acc
    [h, ..t] ->
      if h == item {
        do_index_of([], item, acc)
      } else {
        do_index_of(t, item, acc + 1)
      }
  }
}

fn index_of(self: List<a>, item: a) -> Option<Int> {
  if has(self, item) {
    Some(do_index_of(self, item, 0))
  } else {
    None
  }
}

test index_of_1() {
  let sth =
    index_of([], 2)

  sth == None
}

test index_Of_2() {
  let sth =
    index_of([1, 2, 3], 2)
  expect Some(s) =
    sth

  s == 1
}

test index_of_3() {
  let sth =
    index_of([1, 2, 3], 3)
  expect Some(s) =
    sth

  s == 2
}

test index_of_4() {
  let sth =
    index_of([1, 3], 3)
  expect Some(s) =
    sth

  s == 1
}

fn max(self: List<Int>) -> Option<Int> {
  when self is {
    [] ->
      None
    [first] ->
      Some(first)
    [h, ..t] ->
      Some(foldl(t, fn(a, b) { math.max(a, b) }, h))
  }
}

test max_1() {
  max([]) == None
}

test max_2() {
  max([9]) == Some(9)
}

test max_3() {
  max([9, 8, 1]) == Some(9)
}

test max_4() {
  max([9, 8, 1, -1, 10]) == Some(10)
}

fn min(self: List<Int>) -> Option<Int> {
  when self is {
    [] ->
      None
    [first] ->
      Some(first)
    [h, ..t] ->
      Some(foldl(t, fn(a, b) { math.min(a, b) }, h))
  }
}

test min_1() {
  min([]) == None
}

test min_2() {
  min([9]) == Some(9)
}

test min_3() {
  min([9, 8, 1]) == Some(1)
}

test min_4() {
  min([9, 8, 1, -1]) == Some(-1)
}

pub fn sum(self: List<Int>) -> Int {
  list.foldl(self, fn(a, b) { a + b }, 0)
}

test sum_1() {
  sum([]) == 0
}

test sum_2() {
  sum([1, 2, 3]) == 6
}

test sum_3() {
  sum([1, 2, 3, 4]) == 10
}

pub fn product(self: List<Int>) -> Int {
  list.foldl(self, fn(a, b) { a * b }, 1)
}

test product_1() {
  product([]) == 1
}

test product_2() {
  product([1, 2, 3]) == 6
}

test product_3() {
  product([1, 2, 3, 4]) == 24
}
