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

test take_while_2() {
  take_until([1, 2, 3, 4, 5], fn(x) { x <= 2 }) == [1, 2]
}

test take_while_3() {
  take_until([1, 2, 3, 4, 5], fn(x) { x < 4 }) == [1, 2, 3]
}
