use acca/ordering as aordering
use aiken/dict.{Dict}
use aiken/int
use aiken/list

/// Sort dict given it's comparator for keys.
/// 
/// This method is useful in scenarios where offchain part passes
/// unsorted dictionnary and dictonnaries are to be compared using == operator with
/// on chain construction.
///
/// It is recommended to pass already sorted List<(a, b)> from offchain to onchain
/// instead of using this method.
/// ```
pub fn sort(
  self: Dict<key, value>,
  key_compare: fn(key, key) -> Ordering,
) -> Dict<key, value> {
  let tuple_compare =
    fn(l, r) { aordering.compare_tuple_left(l, r, key_compare) }

  dict.to_list(self)
    |> list.sort(tuple_compare)
    |> dict.from_ascending_list(key_compare)
}

test sort_0() {
  let left: Dict<Int, String> =
    dict.new()
      |> dict.insert(1, @"a", int.compare)
      |> dict.insert(2, @"b", int.compare)
      |> dict.insert(3, @"c", int.compare)

  let right: Dict<Int, String> =
    dict.new()
      |> dict.insert(1, @"a", int.compare)
      |> dict.insert(2, @"b", int.compare)
      |> dict.insert(3, @"c", int.compare)

  sort(left, int.compare) == sort(right, int.compare)
}

test sort_1() {
  let left: Dict<Int, String> =
    dict.new()
      |> dict.insert(1, @"a", int.compare)
      |> dict.insert(2, @"b", int.compare)
      |> dict.insert(3, @"c", int.compare)

  let right: Dict<Int, String> =
    dict.new()
      |> dict.insert(1, @"a", int.compare)
      |> dict.insert(3, @"c", int.compare)
      |> dict.insert(2, @"b", int.compare)

  sort(left, int.compare) == sort(right, int.compare)
}

test sort_2() {
  let left: Dict<Int, String> =
    dict.new()
      |> dict.insert(2, @"b", int.compare)
      |> dict.insert(3, @"c", int.compare)
      |> dict.insert(1, @"a", int.compare)

  let right: Dict<Int, String> =
    dict.new()
      |> dict.insert(1, @"a", int.compare)
      |> dict.insert(3, @"c", int.compare)
      |> dict.insert(2, @"b", int.compare)

  sort(left, int.compare) == sort(right, int.compare)
}
