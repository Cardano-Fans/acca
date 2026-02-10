use acca/ordering as aordering
use aiken/collection/dict.{Dict}
use aiken/collection/list
use aiken/primitive/bytearray

// DEPRECATED: use dict.get_or_else instead of this method.
// /// Gets a given value or returns fallback value in case it is not possible
// /// to find a value given the key.
// ///
// /// ```aiken
// /// let d = dict.new() |> dict.insert(1, True, int.compare)
// /// adict.get_or_default(1, False) == True
// /// adict.get_or_default(2, False) == False
// /// ```
// pub fn get_or_default(self: Dict<key, value>, k: key, fallback: value) -> value {
//   when dict.get(self, k) is {
//     Some(v) -> v
//     None -> fallback
//   }
// }

// test get_or_default_1() {
//   let d = dict.new() |> dict.insert(1, True, int.compare)
//   get_or_default(d, 1, False) == True
// }

// test get_or_default_2() {
//   let d = dict.new() |> dict.insert(1, True, int.compare)
//   get_or_default(d, 2, False) == False
// }

/// Sort dict given it's comparator for keys.
/// 
/// This method is useful in scenarios where off-chain part passes
/// unsorted dictionary and dictionaries are to be compared using == operator with
/// on chain construction.
///
/// It is recommended to pass already sorted List<(a, b)> from off-chain to on-chain
/// instead of using this method.
pub fn sort(
  self: Dict<key, value>,
  key_compare: fn(ByteArray, ByteArray) -> Ordering,
) -> Dict<key, value> {
  let tuple_compare =
    fn(l, r) { aordering.compare_pair_left(l, r, key_compare) }

  dict.to_pairs(self)
    |> list.sort(tuple_compare)
    |> dict.from_ascending_pairs()
}

test sort_0() {
  let left: Dict<Int, String> =
    dict.empty
      |> dict.insert(#[1], @"a")
      |> dict.insert(#[2], @"b")
      |> dict.insert(#[3], @"c")

  let right: Dict<Int, String> =
    dict.empty
      |> dict.insert(#[1], @"a")
      |> dict.insert(#[2], @"b")
      |> dict.insert(#[3], @"c")

  sort(left, bytearray.compare) == sort(right, bytearray.compare)
}

test sort_1() {
  let left: Dict<Int, String> =
    dict.empty
      |> dict.insert(#[1], @"a")
      |> dict.insert(#[2], @"b")
      |> dict.insert(#[3], @"c")

  let right: Dict<Int, String> =
    dict.empty
      |> dict.insert(#[1], @"a")
      |> dict.insert(#[3], @"c")
      |> dict.insert(#[2], @"b")

  sort(left, bytearray.compare) == sort(right, bytearray.compare)
}

test sort_2() {
  let left: Dict<Int, String> =
    dict.empty
      |> dict.insert(#[2], @"b")
      |> dict.insert(#[3], @"c")
      |> dict.insert(#[1], @"a")

  let right: Dict<Int, String> =
    dict.empty
      |> dict.insert(#[1], @"a")
      |> dict.insert(#[3], @"c")
      |> dict.insert(#[2], @"b")

  sort(left, bytearray.compare) == sort(right, bytearray.compare)
}
