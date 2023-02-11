use acca/predicate.{not}
use aiken/list.{at, concat, drop, foldl, has, head, push, reverse, take}
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

// pub fn sliding(self: List<a>, n: Int) -> List<List<a>> {
//   if n <= 0 {
//     []
//   } else {
//     do_sliding(self, [], n)
//   }
// }

// fn do_sliding(tail: List<a>, accum: List<List<a>>, n: Int) -> List<List<a>> {
//   when tail is {
//     [] -> accum
//     all -> {
//       let took = take(all, n)
//       let rest = drop(all, n)
//       let l = last(took)
//       when l is {
//         Some(ll) -> do_sliding(push(rest, ll), concat(accum, [took]), n)
//         None -> do_sliding(rest, concat(accum, [took]), n)
//       }
//     }
//   }
// }

// test sliding_1() {
//   sliding([], 2) == []
// }

// test sliding_2() {
//   let items = sliding([1, 2, 3], 2)
//   expect Some(g1) = at(items, 0)

//   g1 == [1, 2]
// }

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

fn min(self: List<Int>) -> Option<Int> {
  when self is {
    [] -> None
    [first] -> Some(first)
    [h, ..t] -> Some(foldl(t, fn(a, b) { math.min(a, b) }, h))
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

fn max(self: List<Int>) -> Option<Int> {
  when self is {
    [] -> None
    [first] -> Some(first)
    [h, ..t] -> Some(foldl(t, fn(a, b) { math.max(a, b) }, h))
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
// TODO
// sliding, scanLeft, scan, scanRight, takeRight, diff, permutations, combinations, sorted, sortWith
