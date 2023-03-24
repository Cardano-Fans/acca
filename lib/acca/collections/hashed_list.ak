use acca/list as alist
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
      |> list.map(hash_fn)

  let zero =
    sha2_256(#"")

  let hash =
    alist.reduce_left(hashed_items, combine_hash, zero)

  HashedList { inner: hashed_items, hash }
}

test from_1() {
  let items =
    []

  let hashed_list =
    from(items, create_string_item_serialise_fn())

  hashed_list.hash == #"e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
}

test from_2() {
  let dog =
    @"dog"
  let items =
    [dog]

  let hashed_list =
    from(items, create_string_item_serialise_fn())

  hashed_list.hash == #"778a58564343a3eb1b4f22abde3ee16a1846ed730365d32334c5b64338c35a2c"
}

test from_3() {
  let dog =
    @"dog"
  let cat =
    @"cat"
  let items =
    [dog, cat]

  let hashed_list =
    from(items, create_string_item_serialise_fn())

  hashed_list.hash == #"abc48c555c2e7fb968c02bf0a6e6854b7239b3ede1d5745152cc656e430ae845"
}

test from_4() {
  let dog =
    @"dog"
  let cat =
    @"cat"
  let horse =
    @"horse"
  let mouse =
    @"mouse"

  let items =
    [dog, cat, horse, mouse]

  let hashed_list =
    from(items, create_string_item_serialise_fn())

  hashed_list.hash == #"f3b80d721103a0a321bc3b88a946c9c9fc86f5721b61cf012d731b6a1d9efe3b"
}

fn create_string_item_serialise_fn() -> fn(String) -> ByteArray {
  fn(x: String) { sha2_256(bytearray.from_string(x)) }
}
