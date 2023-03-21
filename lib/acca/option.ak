use aiken/list
use aiken/option.{is_some}

/// A function that forces resolution of an item from this option.
///
/// ```aiken
/// afold.force_get(Some(1)) == 1
/// afold.force_get(None) // fails
/// ```
pub fn force_get(self: Option<a>) -> a {
  expect Some(x) = self

  x
}

test force_get_1() {
  force_get(Some(1)) == 1
}

/// A function that given option and a mapper function returning Option
/// eventually returns Option instead of Option<Option><A>
///
/// ```aiken
/// afold.flat_map(Some(1), fn(x: Int) { Some(x + 1) }) == Some(2)
/// afold.flat_map(None, fn(x: Int) { Some(x + 1) }) == None
/// ```
pub fn flat_map(self: Option<a>, with: fn(a) -> Option<b>) -> Option<b> {
  when self is {
    Some(a) -> with(a)
    None -> None
  }
}

test flat_map_1() {
  flat_map(Some(1), fn(x: Int) { Some(x + 1) }) == Some(2)
}

test flat_map_2() {
  flat_map(None, fn(x: Int) { Some(x + 1) }) == None
}

/// Fold is a resolver which allows you to pass two function,
/// one for case when option is empty and one for case where there is a value.
///
/// ```aiken
/// afold.fold(Some(1), with_empty: fn() { @"empty" }, with_present: fn(_) { @"present" }) == @"present"
/// afold.fold(None, with_empty: fn() { @"empty" }, with_present: fn(_) { @"world" }) == @"empty"
/// ```
fn fold(self: Option<a>, with_empty: fn() -> b, with_present: fn(a) -> b) -> b {
  when self is {
    Some(x) -> with_present(x)
    None -> with_empty()
  }
}

test fold_1() {
  fold(Some(1), fn() { False }, fn(_) { True }) == True
}

test fold_2() {
  fold(None, fn() { False }, fn(_) { True }) == False
}

/// Returns a element only if it is matching a given predicate.
///
/// ```aiken
/// aoption.filter(Some(1), fn(x) { x == 1 }) == Some(1)
/// aoption.filter(Some(0), fn(x) { x == 1 }) == None
/// ```
fn filter(self: Option<a>, with: fn(a) -> Bool) -> Option<a> {
  when self is {
    Some(x) ->
      if with(x) {
        Some(x)
      } else {
        None
      }
    None -> None
  }
}

test filter_1() {
  filter(Some(1), fn(x) { x == 1 }) == Some(1)
}

test filter_2() {
  filter(Some(0), fn(x) { x == 1 }) == None
}

/// Whether an element matching a given predicate is present in this option.
///
/// ```aiken
/// aoption.exists(Some(1), fn(x) { x == 1 }) == True
/// aoption.exists(Some(0), fn(x) { x == 1 }) == False
/// ```
fn exists(self: Option<a>, with: fn(a) -> Bool) -> Bool {
  is_some(filter(self, with))
}

test exists_1() {
  exists(Some(1), fn(x) { x == 0 }) == False
}

test exists_2() {
  exists(Some(1), fn(x) { x == 1 }) == True
}

/// Resolves items from the list such that it keeps only Some items and filters out None items.
///
/// ```aiken
/// aoption.resolve([Some(1), None, Some(2)]) == [Some(1), Some(2)]
/// ```
pub fn resolve(self: List<Option<a>>) -> List<Option<a>> {
  list.filter(self, fn(opt) { is_some(opt) })
}

test resolve_1() {
  let items: List<Option<Int>> = [Some(1), None, Some(2)]

  resolve(items) == [Some(1), Some(2)]
}

test resolve_2() {
  let items: List<Option<Int>> = [None]

  resolve(items) == []
}

test resolve_3() {
  let items: List<Option<Int>> = []

  resolve(items) == []
}
