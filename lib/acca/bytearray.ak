use aiken/bytearray

/// Convert a `ByteArray` from hexadecimal into the integer representation.
/// This implementation uses BigEndian notation (also called network order),
/// where data is represented sequentially starting from the most significant
/// bit to the least significant.
///
/// ```aiken
/// bytearray.to_int(#"") == 0
/// bytearray.to_int(#"414243") == 4276803
/// ```
pub fn to_int(self: ByteArray) -> Int {
  bytearray.foldl(self, fn(byte, acc) { acc * 256 + byte }, 0)
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
