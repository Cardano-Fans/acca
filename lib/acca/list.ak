use acca/predicate.{not}
use aiken/list.{
  at, concat, drop, filter, foldl, has, head, push, reverse, take, unique,
}
use aiken/math

pub fn first(self: List<a>) -> Option<a> {
  head(self)
}

pub fn last(self: List<a>) -> Option<a> {
  self
  |> reverse
  |> head
}

test last_1() {
  last([]) == None
}

test last_2() {
  last([1]) == Some(1)
}

test last_3() {
  last([1, 2, 3]) == Some(3)
}

pub fn non_empty(self: List<a>) -> Bool {
  when self is {
    [] -> False
    _ -> True
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
    [] -> reverse(accum)
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

fn do_take_while(
  tail: List<a>,
  accum: List<a>,
  predicate: fn(a) -> Bool,
) -> List<a> {
  when tail is {
    [] -> reverse(accum)
    [h, ..t] ->
      if predicate(h) {
        do_take_while(t, push(accum, h), predicate)
      } else {
        do_take_while(t, accum, predicate)
      }
  }
}

pub fn take_while(self: List<a>, predicate: fn(a) -> Bool) -> List<a> {
  do_take_while(self, [], predicate)
}

test take_while_1() {
  take_while([], fn(x) { x > 0 }) == []
}

test take_while_2() {
  take_while([1, 2, 3, 4, 5], fn(x) { x <= 2 }) == [1, 2]
}

test take_while_3() {
  take_while([1, 2, 3, 4, 5], fn(x) { x < 4 }) == [1, 2, 3]
}

test take_while_4() {
  take_while([1, 2, 3, 4, 5], fn(x) { x != 4 }) == [1, 2, 3, 5]
}

pub fn drop_while(self: List<a>, predicate: fn(a) -> Bool) -> List<a> {
  do_take_while(self, [], not(predicate))
}

test drop_while_1() {
  drop_while([], fn(x) { x > 0 }) == []
}

test drop_while_2() {
  drop_while([1, 2, 3, 4, 5], fn(x) { x <= 2 }) == [3, 4, 5]
}

test drop_while_3() {
  drop_while([1, 2, 3, 4, 5], fn(x) { x < 4 }) == [4, 5]
}

test drop_while_4() {
  drop_while([1, 2, 3, 4, 5], fn(x) { x != 4 }) == [4]
}

pub fn filter_not(self: List<a>, predicate: fn(a) -> Bool) -> List<a> {
  filter(self, not(predicate))
}

test filter_not_1() {
  filter_not([1, 2, 3], fn(x) { x == 1 }) == [2, 3]
}

pub fn partition(self: List<a>, predicate: fn(a) -> Bool) -> (List<a>, List<a>) {
  let l = take_while(self, predicate)
  let r = drop_while(self, predicate)
  (l, r)
}

test partition_1() {
  let (l, r) = partition([], fn(x) { x <= 3 })

  [] == l && [] == r
}

test partition_2() {
  let (l, r) = partition([1, 2, 3, 4, 5], fn(x) { x <= 3 })

  [1, 2, 3] == l && [4, 5] == r
}

test partition_3() {
  let (l, r) = partition([1, 2], fn(x) { x <= 1 })

  [1] == l && [2] == r
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
    [] -> accum
    all -> {
      let took = take(all, n)
      let rest = drop(all, n)
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
  let items = grouped([1, 2, 3, 4, 5, 6], 2)
  expect Some(g1) = at(items, 0)
  expect Some(g2) = at(items, 1)
  expect Some(g3) = at(items, 2)

  g1 == [1, 2] && g2 == [3, 4] && g3 == [5, 6]
}

test grouped_3() {
  let items = grouped([1, 2, 3], 1)
  expect Some(g1) = at(items, 0)
  expect Some(g2) = at(items, 1)
  expect Some(g3) = at(items, 2)

  g1 == [1] && g2 == [2] && g3 == [3]
}

test grouped_4() {
  let items = grouped([1, 2, 3, 4, 5, 6], 3)
  expect Some(g1) = at(items, 0)
  expect Some(g2) = at(items, 1)

  g1 == [1, 2, 3] && g2 == [4, 5, 6]
}

test grouped_5() {
  [] == grouped([1, 2, 3, 4, 5, 6], 0)
}

test grouped_6() {
  [] == grouped([1, 2, 3, 4, 5, 6], -1)
}

pub fn diff(self1: List<a>, self2: List<a>) -> List<a> {
  let diff = filter(self1, fn(x) { !has(self2, x) })

  unique(diff)
}

test diff_1() {
  diff([1, 2], [1, 3]) == [2]
}

test diff_2() {
  diff([1, 2, 3], [1, 2, 3]) == []
}

test diff_3() {
  diff([], []) == []
}

test diff_4() {
  diff([1, 2, 3, 4], [1, 3]) == [2, 4]
}

pub fn bi_diff(self1: List<a>, self2: List<a>) -> List<a> {
  let diff1 = filter(self1, fn(x) { !has(self2, x) })
  let diff2 = filter(self2, fn(x) { !has(self1, x) })

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
    [] -> accum
    [_] -> accum
    all -> {
      let took = take(all, n)
      let rest = drop(all, n)
      let l = last(took)
      when l is {
        Some(ll) -> do_sliding(push(rest, ll), concat(accum, [took]), n)
        _ -> do_sliding([], concat(accum, [took]), n)
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
  let items = sliding([1, 2, 3], 2)
  expect Some(g1) = at(items, 0)
  expect Some(g2) = at(items, 1)

  g1 == [1, 2] && g2 == [2, 3]
}

test sliding_5() {
  let items = sliding([1, 2, 3, 4, 5], 2)
  expect Some(g1) = at(items, 0)
  expect Some(g2) = at(items, 1)
  expect Some(g3) = at(items, 2)
  expect Some(g4) = at(items, 3)

  g1 == [1, 2] && g2 == [2, 3] && g3 == [3, 4] && g4 == [4, 5]
}

test sliding_6() {
  let items = sliding([1, 2, 3, 4, 5, 6], 3)
  expect Some(g1) = at(items, 0)
  expect Some(g2) = at(items, 1)
  expect Some(g3) = at(items, 2)

  g1 == [1, 2, 3] && g2 == [3, 4, 5] && g3 == [5, 6]
}

test sliding_7() {
  let items = sliding([1, 2, 3, 4, 5], 3)
  expect Some(g1) = at(items, 0)
  expect Some(g2) = at(items, 1)

  g1 == [1, 2, 3] && g2 == [3, 4, 5]
}

test sliding_8() {
  sliding([1, 2, 3, 4, 5], 1) == []
}

fn indices(self: List<a>) -> List<Int> {
  when self is {
    [] -> []
    _ -> {
      let len = list.length(self)
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
    [] -> acc
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
  let sth = index_of([], 2)

  sth == None
}

test index_Of_2() {
  let sth = index_of([1, 2, 3], 2)
  expect Some(s) = sth

  s == 1
}

test index_of_3() {
  let sth = index_of([1, 2, 3], 3)
  expect Some(s) = sth

  s == 2
}

test index_of_4() {
  let sth = index_of([1, 3], 3)
  expect Some(s) = sth

  s == 1
}

fn do_slice_until(
  tail: List<a>,
  from: Int,
  to: Int,
  index: Int,
  accum: List<a>,
) -> List<a> {
  when tail is {
    [] -> reverse(accum)
    [h, ..t] ->
      if index >= from && index < to {
        do_slice_until(t, from, to, index + 1, push(accum, h))
      } else {
        do_slice_until([], from, to, index, accum)
      }
  }
}

pub fn slice(self: List<a>, from: Int, to: Int) -> List<a> {
  if from < 0 || to < 0 || from == to {
    []
  } else {
    do_slice_until(self, from, to, from, [])
  }
}

test slice_1() {
  slice([1, 3, 4], 1, -1) == []
}

test slice_2() {
  slice([1, 3, 4], -1, 1) == []
}

test slice_3() {
  slice([1, 3, 4], 0, 0) == []
}

test slice_4() {
  slice([1, 3, 4], 0, 1) == [1]
}

test slice_5()) {
  slice([1, 3, 4], 0, 2) == [1, 3]
}

test slice_6() {
  slice([1, 3, 4], 0, 10) == [1, 3, 4]
}

test slice_7() {
  slice([1, 3, 4], 0, 3) == [1, 3, 4]
}

test slice_8() {
  slice([1, 3, 4], 0, 3) == [1, 3, 4]
}

// Sort list by a certain predicate.
// pub fn sort_by(xs: List<a>, f: fn(a, a) -> Int) -> List<a> {
//   do_merge_all(do_sequences(xs, f), f)
// }

// test sort_by_1() {
//   let xs = [4, 3, 2, 1]
//   sort_by(xs, fn(a, b) { a - b }) == [1, 2, 3, 4]
// }

// fn do_sequences(xs: List<a>, f: fn(a, a) -> Int) -> List<List<a>> {
//   when xs is {
//     [x, y, ..rest] ->
//       if f(x, y) > 0 {
//         do_descending(y, [x], rest, f)
//       } else {
//         do_ascending(y, [x], rest, f)
//       }
//     xs -> [xs]
//   }
// }

// fn do_descending(
//   x: a,
//   xs: List<a>,
//   rest: List<a>,
//   f: fn(a, a) -> Int,
// ) -> List<List<a>> {
//   let [y, ..ys] = rest
//   if f(x, y) > 0 {
//     do_descending(y, [x, ..xs], ys, f)
//   } else {
//     [[x, ..xs], ..do_sequences(rest, f)]
//   }
// }

// fn do_ascending(
//   x: a,
//   xs: List<a>,
//   rest: List<a>,
//   f: fn(a, a) -> Int,
// ) -> List<List<a>> {
//   let [y, ..ys] = rest
//   if f(x, y) <= 0 {
//     do_ascending(y, concat(xs, [x]), ys, f)
//   } else {
//     [concat(xs, [x]), ..do_sequences(rest, f)]
//   }
// }

// fn do_merge(xs: List<a>, ys: List<a>, f: fn(a, a) -> Int) -> List<a> {
//   when [xs, ys] is {
//     [[], ys] -> ys
//     [xs, []] -> xs
//     [[x, ..xs2], [y, ..ys2]] ->
//       if f(x, y) > 0 {
//         [y, ..do_merge(xs, ys2, f)]
//       } else {
//         [x, ..do_merge(xs2, ys, f)]
//       }
//   }
// }

// fn do_merge_pairs(xs: List<List<a>>, f: fn(a, a) -> Int) -> List<List<a>> {
//   when xs is {
//     [x, y, ..rest] -> [do_merge(x, y, f), ..do_merge_pairs(rest, f)]
//     xs -> xs
//   }
// }

// fn do_merge_all(xs: List<List<a>>, f: fn(a, a) -> Int) -> List<a> {
//   when xs is {
//     [x] -> x
//     xs -> do_merge_all(do_merge_pairs(xs, f), f)
//   }
// }
// TODO
// scanLeft, scan, scanRight, takeRight, permutations, combinations, sorted, sortWith
