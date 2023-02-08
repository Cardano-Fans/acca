use aiken/list.{concat, drop, head, reverse}

/// Returns Some(item) or None given index, note that counting of index is starting from 0
pub fn at(self: List<a>, index: Int) -> Option<a> {
  let skipped = drop(self, index)
  when skipped is {
    [] -> None
    all -> head(all)
  }
}

test at_1() {
  at([], -1) == None
}

test at_2() {
  at([], 0) == None
}

test at_3() {
  at([1, 2, 3], 3) == None
}

test at_4() {
  at([1], 0) == Some(1)
}

test at_5() {
  at([1, 2, 3], 2) == Some(3)
}

test at_6() {
  at([1, 2, 3], 1) == Some(2)
}

test at_7() {
  at([1, 2, 3], 0) == Some(1)
}

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
