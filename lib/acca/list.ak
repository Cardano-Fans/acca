use acca/option as aoption
use acca/predicate.{not}
use aiken/dict.{Dict}
use aiken/list.{concat, head, reverse}

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

pub fn is_empty(self: List<a>) -> Bool {
  when self is {
    [] -> True
    _ -> False
  }
}

test is_empty_1() {
  is_empty([])
}

test is_empty_2() {
  is_empty([1]) == False
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

/// Prepends an element to the beginning of the list
pub fn prepend(self: List<a>, item: a) -> List<a> {
  concat([item], self)
}

test prepend_1() {
  prepend([], 1) == [1]
}

test prepend_2() {
  prepend([1, 2, 3], 0) == [0, 1, 2, 3]
}

/// Appends an element to the end of the list
pub fn append(self: List<a>, item: a) -> List<a> {
  concat(self, [item])
}

test append_1() {
  prepend([], 1) == [1]
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
        do_take_until(t, prepend(accum, h), predicate)
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
        do_take_while(t, prepend(accum, h), predicate)
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

pub fn group_by(
  self: List<a>,
  predicate: fn(a) -> Bool,
) -> Dict<ByteArray, List<a>> {
  let (l, r) = partition(self, predicate)

  dict.new()
  |> dict.insert(#"00", l)
  |> dict.insert(#"01", r)
}

test group_by_1() {
  let d: Dict<ByteArray, List<Int>> =
    group_by([1, 2, 3, 4, 5], fn(x) { x <= 3 })

  let l =
    dict.get(d, #"00")
    |> aoption.get()

  let r =
    dict.get(d, #"01")
    |> aoption.get()

  l == [1, 2, 3] && r == [4, 5]
}
