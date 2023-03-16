use aiken/bytearray
use aiken/hash.{Hash, Sha2_256, sha2_256}
use aiken/list

pub type HashedList<a> {
  inner: List<Hash<Sha2_256, a>>,
  hash: Hash<Sha2_256, a>,
}

fn combine_hash(
  left: Hash<Sha2_256, a>,
  right: Hash<Sha2_256, a>,
) -> Hash<Sha2_256, a> {
  sha2_256(bytearray.concat(left, right))
}

pub fn from(
  items: List<a>,
  hash_fn: fn(a) -> Hash<Sha2_256, a>,
) -> HashedList<a> {
  let hashed_items =
    items
      |> list.map(fn(item) { hash_fn(item) })

  let zero = sha2_256(#"")

  let reducer = fn(a, b) { combine_hash(a, b) }

  let hash = list.foldl(hashed_items, reducer, zero)

  HashedList { inner: hashed_items, hash }
}

test from_1() {
  let items = []

  let hashed_list = from(items, create_string_item_serialise_fn())

  hashed_list.hash == #"e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
}

test from_2() {
  let dog = @"dog"
  let cat = @"cat"
  let items = [dog, cat]

  let hashed_list = from(items, create_string_item_serialise_fn())

  hashed_list.hash == #"e0437181546685b18b3d8ce1cd181fe63e0b05e5cafe9757b04dbf8edb7996e2"
}

fn create_string_item_serialise_fn() -> fn(String) -> ByteArray {
  fn(x: String) { bytearray.from_string(x) }
}