use aiken/bytearray
use aiken/string

pub fn compare(left: String, right: String) -> Ordering {
  bytearray.compare(string.to_bytearray(left), string.to_bytearray(right))
}
