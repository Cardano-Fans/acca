use aiken/builtin
use aiken/bytearray

/// Attest whether a given list of byte array is in fact sorted.
///
/// ```aiken
/// abytearray.is_sorted([#"aa", #"bb"]) == True
/// abytearray.is_sorted([#"bb", #"aa"]) == False
/// ```
fn is_sorted(l: List<ByteArray>) -> Bool {
  when l is {
    [] -> True
    [_x] -> True
    [x, y, ..xs] -> builtin.less_than_bytearray(x, y) && is_sorted([y, ..xs])
  }
}

test is_sorted_1() {
  is_sorted([#"aa", #"bb"])
}

test is_sorted_2() {
  is_sorted([#"bb", #"aa"]) == False
}

/// Convert a `ByteArray` from hexadecimal into the integer representation.
/// This implementation uses BigEndian notation (also called network order),
/// where data is represented sequentially starting from the most significant
/// bit to the least significant.
///
/// ```aiken
/// abytearray.to_int(#"") == 0
/// abytearray.to_int(#"414243") == 4276803
/// ```
pub fn to_int(self: ByteArray) -> Int {
  bytearray.foldl(self, 0, fn(byte, acc) { acc * 256 + byte })
}

test empty_bytearray_to_int() {
  to_int(#"") == 0
}

test short_bytearray_to_int() {
  to_int(#"acab") == 44203
}

test bytearray_to_int() {
  let x = #"356cf088720a169dae0ce0bb1df8588944389fa43322f0d6ef4ed8c069bfd405"
  to_int(x) == 24165060555594911913195642527692216679757672038384202527929620681761931383813
}
