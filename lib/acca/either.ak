//// Represents a value of one of two possible types (a disjoint union). An instance of Either is an instance of either `Left` or `Right`.

use aiken/list

/// A common use of Either is as an alternative to an Option for dealing with possibly missing values. In this usage, None is replaced with a `Left` which can contain useful information. `Right` takes the place of scala.Some. Convention dictates that `Left` is used for failure and `Right` is used for success.
/// For example, you could use Either<String, Int> to indicate whether a received input is a String or an Int.
pub type Either<a, b> {
  Left { value: a }
  Right { value: b }
}

test either_1() {
  let l: Either<Int, String> =
    Left { value: 1 }
  let r: Either<Int, String> =
    Right { value: @"" }

  list.and([l == Left { value: 1 }, r == Right { value: @"" }])
}

/// Forces either to be `Left`, fails with an error otherwise.
pub fn left(self: Either<a, b>) {
  expect Left { value } =
    self

  value
}

test left_1() {
  left(Left { value: 1 }) == 1
}

/// Forces either to be `Right`, fails with an error otherwise.
pub fn right(self: Either<a, b>) {
  expect Right { value } =
    self

  value
}

test right_1() {
  right(Right { value: 1 }) == 1
}

/// Provides information whether `Either` contains a particular element.
pub fn contains(self: Either<a, b>, item: b) -> Bool {
  when self is {
    Left(_) ->
      False
    Right(x) ->
      x == item
  }
}

test contains_1() {
  contains(Left { value: 1 }, 1) == False
}

test contains_2() {
  contains(Left { value: 1 }, 0) == False
}

test contains_3() {
  contains(Right { value: 1 }, 1)
}

/// Fold allows to reduce `Either` to one value, there is a with_left function to reduce which reduces `Left` either and with_right which is used to reduce `Right` either.
pub fn fold(
  self: Either<a, b>,
  with_left: fn(a) -> c,
  with_right: fn(b) -> c,
) -> c {
  when self is {
    Left(a) ->
      with_left(a)
    Right(b) ->
      with_right(b)
  }
}

test fold_1() {
  let either: Either<Int, Int> =
    Left { value: 1 }

  fold(self: either, with_left: fn(x) { x > 0 }, with_right: fn(y) { y < 0 }) == True
}

test fold_2() {
  let either: Either<Int, Int> =
    Right { value: 1 }

  fold(self: either, with_left: fn(x) { x > 0 }, with_right: fn(y) { y < 0 }) == False
}

/// Allows to convert either to Option, where `Left` part is converted to None and `Right` part to Some.
/// Notice that coversion of `Left` to None means we are loosing value wrapped in `Left`.
pub fn to_option(self: Either<a, b>) -> Option<b> {
  when self is {
    Left(_) ->
      None
    Right(x) ->
      Some(x)
  }
}

test to_option_1() {
  to_option(Left { value: 1 }) == None
}

test to_option_2() {
  to_option(Right { value: 1 }) == Some(1)
}

/// Convert Either to a list.
/// `Left` (usually represents errors) will be converted to an empty list
/// `Right` will be converted to a list of one element
pub fn to_list(self: Either<a, b>) -> List<b> {
  when self is {
    Left(_) ->
      []
    Right(x) ->
      [x]
  }
}

test to_list_1() {
  to_list(Left { value: 1 }) == []
}

test to_list_2() {
  to_list(Right { value: 1 }) == [1]
}

/// Whether this either is in fact `Left`.
pub fn is_left(self: Either<a, b>) -> Bool {
  when self is {
    Left(_) ->
      True
    _ ->
      False
  }
}

/// Whether this either is in fact `Right`.
pub fn is_right(self: Either<a, b>) -> Bool {
  when self is {
    Right(_) ->
      True
    _ ->
      False
  }
}

/// Applies the predicate to the `Right` part, in case Either is `Left`, it returns negative.
pub fn exists(self: Either<a, b>, with: fn(b) -> Bool) -> Bool {
  when self is {
    Left(_) ->
      False
    Right(y) ->
      if with(y) {
        True
      } else {
        False
      }
  }
}

test exists_1() {
  exists(Left { value: 1 }, fn(x) { x }) == False
}

test exists_2() {
  exists(Right { value: 1 }, fn(x) { x > 0 }) == True
}

test exists_3() {
  exists(Right { value: -1 }, fn(x) { x > 0 }) == False
}

/// Swap and replace a `Left` side with a `Right` side.
pub fn swap(self: Either<a, b>) -> Either<b, a> {
  when self is {
    Left(x) ->
      Right(x)
    Right(y) ->
      Left(y)
  }
}

test swap_1() {
  swap(Right { value: 1 }) == Left { value: 1 }
}

test swap_2() {
  swap(Left { value: 1 }) == Right { value: 1 }
}

/// Ability to transform (map) `Right` `Left` with a given mapping function. `Left` returns value without transformation / mapping.
/// Note that map is right biased, if you need to map over left, you should use map_left function.
pub fn map(self: Either<a, b>, with: fn(b) -> c) {
  when self is {
    Left(x) ->
      Left(x)
    Right(y) ->
      Right(with(y))
  }
}

/// Alias for map
pub fn map_right(self: Either<a, b>, with: fn(b) -> c) {
  map(self, with)
}

test map_1() {
  map(Right { value: 12 }, fn(x) { x + 1 }) == Right { value: 13 }
}

test map_2() {
  map(Left { value: 12 }, fn(x) { x + 1 }) == Left { value: 12 }
}

pub fn map_left(self: Either<a, b>, with: fn(a) -> c) {
  when self is {
    Left(x) ->
      Left(with(x))
    Right(y) ->
      Right(y)
  }
}

test map_left_1() {
  map_left(Right { value: 12 }, fn(x) { x + 1 }) == Right { value: 12 }
}

test map_left_2() {
  map_left(Left { value: 12 }, fn(x) { x + 1 }) == Left { value: 13 }
}
