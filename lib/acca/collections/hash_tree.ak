use aiken/bytearray.{from_string}
use aiken/hash.{Hash, Sha2_256, sha2_256}
use aiken/list
use aiken/option.{choice, is_none}

/// Data structure similar to Merkle Tree called colloquially `Hash Tree`. Contrary to the original
/// it doesn't store the original element.
pub opaque type HashTree<a> {
  Empty
  Leaf { hash: Hash<Sha2_256, a> }
  Node { hash: Hash<Sha2_256, a>, left: HashTree<a>, right: HashTree<a> }
}

pub type Proof<a> =
  List<ProofItem<a>>

pub type ProofItem<a> {
  Left { hash: Hash<Sha2_256, a> }
  Right { hash: Hash<Sha2_256, a> }
}

// Function returning a hash of a given Hash Tree element
pub fn element_hash(self: HashTree<a>) -> Hash<Sha2_256, a> {
  when self is {
    Empty -> #""
    Leaf { hash } -> hash
    Node { hash, .. } -> hash
  }
}

test element_hash_1() {
  let dog = @"dog"
  let items =
    [dog]
  let serialise_fn = create_string_item_serialise_fn()

  let mt = from_list(items, serialise_fn)

  let node_hash = sha2_256(serialise_fn(dog))

  element_hash(mt) == node_hash
}

test element_hash_3() {
  let dog = @"dog"
  let cat = @"cat"
  let mouse = @"mouse"
  let items =
    [dog, cat, mouse]
  let serialise_fn = create_string_item_serialise_fn()

  let mt = from_list(items, serialise_fn)

  let node_hash =
    sha2_256(
      bytearray.concat(
        sha2_256(serialise_fn(cat)),
        sha2_256(serialise_fn(mouse)),
      ),
    )
  let rh = sha2_256(bytearray.concat(sha2_256(serialise_fn(dog)), node_hash))

  expect Node { hash: element_hash, .. } = mt

  rh == element_hash
}

test element_hash_2() {
  let items =
    []
  let serialise_fn = create_string_item_serialise_fn()
  let mt = from_list(items, serialise_fn)

  let node_hash = #""

  element_hash(mt) == node_hash
}

/// Function atests whether two Hash Tress are equal, this is the case when their root hashes match.
pub fn is_equal(left: HashTree<a>, right: HashTree<a>) -> Bool {
  element_hash(left) == element_hash(right)
}

/// Function returns a total numbers of leaves in the tree.
pub fn size(self: HashTree<a>) -> Int {
  when self is {
    Empty -> 0
    Leaf { .. } -> 1
    Node { left, right, .. } -> size(left) + size(right)
  }
}

test size_1() {
  let items =
    []
  let serialise_fn = create_string_item_serialise_fn()
  let mt = from_list(items, serialise_fn)
  size(mt) == 0
}

test size_2() {
  let dog = @"dog"
  let cat = @"cat"
  let mouse = @"mouse"
  let serialise_fn = create_string_item_serialise_fn()

  let mt = from_list([dog, cat, mouse], serialise_fn)
  size(mt) == 3
}

test size_3() {
  let dog = @"dog"
  let cat = @"cat"
  let mouse = @"mouse"
  let items =
    [dog, cat, mouse]
  let serialise_fn = create_string_item_serialise_fn()

  let mt = from_list(items, serialise_fn)
  size(mt) == 3
}

test size_4() {
  let dog = @"dog"
  let cat = @"cat"
  let mouse = @"mouse"
  let horse = @"horse"
  let pig = @"pig"
  let bull = @"bull"

  let serialise_fn = create_string_item_serialise_fn()
  let items =
    [dog, cat, mouse, horse, pig, bull]

  let mt = from_list(items, serialise_fn)
  size(mt) == 6
}

fn combine_hash(
  left: Hash<Sha2_256, a>,
  right: Hash<Sha2_256, a>,
) -> Hash<Sha2_256, a> {
  sha2_256(bytearray.concat(left, right))
}

/// Function that returns whether merkle tree has any elements
pub fn is_empty(self: HashTree<a>) -> Bool {
  when self is {
    Empty -> True
    _ -> False
  }
}

test is_empty_1() {
  let mt = Empty

  is_empty(mt)
}

test is_empty_2() {
  let dog = @"dog"
  let hash = create_string_item_serialise_fn()

  let mt = Leaf { hash: hash(dog) }

  is_empty(mt) == False
}

fn do_proof(
  self: HashTree<a>,
  item_hash: Hash<Sha2_256, a>,
  proof: Proof<a>,
  serialise_fn: fn(a) -> ByteArray,
) -> Option<Proof<a>> {
  when self is {
    Empty -> None
    Leaf { hash } ->
      if hash == item_hash {
        Some(proof)
      } else {
        None
      }
    Node { left, right, .. } -> {
      let rh = element_hash(right)
      let lh = element_hash(left)
      let go_left: Option<Proof<a>> =
        do_proof(
          left,
          item_hash,
          list.push(proof, Right { hash: rh }),
          serialise_fn,
        )
      let go_right: Option<Proof<a>> =
        do_proof(
          right,
          item_hash,
          list.push(proof, Left { hash: lh }),
          serialise_fn,
        )
      choice([go_left, go_right])
    }
  }
}

/// Construct a membership 'Proof' from an element and a 'HashTree'. Returns
/// 'None' if the element isn't a member of the tree to begin with.
/// Note function will return Some([]) in case root of the tree is also it's only one and only element
pub fn get_proof(
  self: HashTree<a>,
  item: a,
  serialise_fn: fn(a) -> ByteArray,
) -> Option<Proof<a>> {
  let empty: Proof<a> =
    []

  do_proof(self, sha2_256(serialise_fn(item)), empty, serialise_fn)
}

test get_proof_1() {
  let dog = @"dog"
  let cat = @"cat"
  let mouse = @"mouse"
  let horse = @"horse"
  let pig = @"pig"
  let bull = @"bull"

  let items =
    [dog, cat, mouse, horse, pig, bull]
  let serialise_fn = create_string_item_serialise_fn()

  let mt = from_list(items, serialise_fn)
  let serialise_fn = create_string_item_serialise_fn()

  let maybe_proof: Option<Proof<String>> =
    get_proof(mt, @"parrot", serialise_fn)

  is_none(maybe_proof)
}

test get_proof_2() {
  let dog = @"dog"

  let items =
    [dog]
  let serialise_fn = create_string_item_serialise_fn()
  let mt = from_list(items, serialise_fn)

  let maybe_proof: Option<Proof<String>> = get_proof(mt, dog, serialise_fn)

  expect Some(proof) = maybe_proof

  // when proof is empty list it actually means that root of the tree is in fact element
  proof == []
}

test get_proof_3() {
  let dog = @"dog"
  let cat = @"cat"
  let mouse = @"mouse"

  let items =
    [dog, cat, mouse]

  let serialise_fn = create_string_item_serialise_fn()
  let mt = from_list(items, serialise_fn)

  let node_hash =
    sha2_256(
      bytearray.concat(
        sha2_256(serialise_fn(cat)),
        sha2_256(serialise_fn(mouse)),
      ),
    )

  let maybe_proof: Option<Proof<String>> = get_proof(mt, dog, serialise_fn)

  expect Some(proof) = maybe_proof

  let size_match = list.length(proof) == 1

  expect Some(p1) = list.at(proof, 0)

  let h1: ByteArray = get_proof_item_value(p1)
  let hash_match = h1 == node_hash

  and {
    size_match?,
    hash_match?,
  }
}

test get_proof_4() {
  let dog = @"dog"
  let cat = @"cat"
  let mouse = @"mouse"
  let horse = @"horse"

  let items =
    [dog, cat, mouse, horse]
  let serialise_fn = create_string_item_serialise_fn()
  let mt = from_list(items, serialise_fn)

  let right_node_hash =
    sha2_256(
      bytearray.concat(
        sha2_256(serialise_fn(mouse)),
        sha2_256(serialise_fn(horse)),
      ),
    )
  let maybe_proof: Option<Proof<String>> = get_proof(mt, dog, serialise_fn)

  expect Some(proof) = maybe_proof

  let size_match = list.length(proof) == 2

  expect Some(p1) = list.at(proof, 0)
  expect Some(p2) = list.at(proof, 1)

  let h1: ByteArray = get_proof_item_value(p1)
  let h2: ByteArray = get_proof_item_value(p2)

  size_match && h1 == sha2_256(serialise_fn(cat)) && h2 == right_node_hash
}

fn do_from_list(
  items: List<a>,
  len: Int,
  serialise_fn: fn(a) -> ByteArray,
) -> HashTree<a> {
  when items is {
    [] -> Empty
    [item] -> {
      let hashed_item = sha2_256(serialise_fn(item))
      Leaf { hash: hashed_item }
    }
    all -> {
      let cutoff: Int = len / 2
      let left =
        all
          |> list.take(cutoff)
          |> do_from_list(cutoff, serialise_fn)
      let right =
        all
          |> list.drop(cutoff)
          |> do_from_list(len - cutoff, serialise_fn)
      let hash = combine_hash(element_hash(left), element_hash(right))
      Node { hash, left, right }
    }
  }
}

/// Construct a 'HashTree' from a list of elements.
/// Note that, while this operation is doable on-chain, it is expensive and
/// preferably done off-chain.
pub fn from_list(
  items: List<a>,
  serialise_fn: fn(a) -> ByteArray,
) -> HashTree<a> {
  do_from_list(items, list.length(items), serialise_fn)
}

test from_1() {
  let items =
    []
  let serialise_fn = create_string_item_serialise_fn()
  let mt = from_list(items, serialise_fn)

  Empty == mt
}

test from_2() {
  let dog = @"dog"
  let items =
    [dog]
  let serialise_fn = create_string_item_serialise_fn()
  let mt = from_list(items, serialise_fn)

  Leaf { hash: sha2_256(serialise_fn(dog)) } == mt
}

test from_3() {
  let dog = @"dog"
  let cat = @"cat"
  let items =
    [dog, cat]

  let serialise_fn = create_string_item_serialise_fn()
  let mt = from_list(items, serialise_fn)

  let element_hash =
    sha2_256(
      bytearray.concat(sha2_256(serialise_fn(dog)), sha2_256(serialise_fn(cat))),
    )

  Node {
    hash: element_hash,
    left: Leaf { hash: sha2_256(serialise_fn(dog)) },
    right: Leaf { hash: sha2_256(serialise_fn(cat)) },
  } == mt
}

test from_4() {
  let dog = @"dog"
  let cat = @"cat"
  let mouse = @"mouse"

  let items =
    [dog, cat, mouse]
  let serialise_fn = create_string_item_serialise_fn()

  let mt = from_list(items, serialise_fn)

  let node_hash =
    sha2_256(
      bytearray.concat(
        sha2_256(serialise_fn(cat)),
        sha2_256(serialise_fn(mouse)),
      ),
    )
  let element_hash =
    sha2_256(bytearray.concat(sha2_256(serialise_fn(dog)), node_hash))

  Node {
    hash: element_hash,
    left: Leaf { hash: sha2_256(serialise_fn(dog)) },
    right: Node {
      hash: node_hash,
      left: Leaf { hash: sha2_256(serialise_fn(cat)) },
      right: Leaf { hash: sha2_256(serialise_fn(mouse)) },
    },
  } == mt
}

test from_5() {
  let dog = @"dog"
  let cat = @"cat"
  let mouse = @"mouse"
  let horse = @"horse"

  let serialise_fn = create_string_item_serialise_fn()

  let items =
    [dog, cat, mouse, horse]
  let mt = from_list(items, serialise_fn)

  let left_node_hash =
    sha2_256(
      bytearray.concat(sha2_256(serialise_fn(dog)), sha2_256(serialise_fn(cat))),
    )
  let right_node_hash =
    sha2_256(
      bytearray.concat(
        sha2_256(serialise_fn(mouse)),
        sha2_256(serialise_fn(horse)),
      ),
    )

  let element_hash = sha2_256(bytearray.concat(left_node_hash, right_node_hash))

  Node {
    hash: element_hash,
    left: Node {
      hash: left_node_hash,
      left: Leaf { hash: sha2_256(serialise_fn(dog)) },
      right: Leaf { hash: sha2_256(serialise_fn(cat)) },
    },
    right: Node {
      hash: right_node_hash,
      left: Leaf { hash: sha2_256(serialise_fn(mouse)) },
      right: Leaf { hash: sha2_256(serialise_fn(horse)) },
    },
  } == mt
}

fn do_from_hashes_list(items: List<Hash<Sha2_256, a>>, len: Int) -> HashTree<a> {
  when items is {
    [] -> Empty
    [hashed_item] -> Leaf { hash: hashed_item }
    all -> {
      let cutoff: Int = len / 2
      let left =
        all
          |> list.take(cutoff)
          |> do_from_hashes_list(cutoff)
      let right =
        all
          |> list.drop(cutoff)
          |> do_from_hashes_list(len - cutoff)
      let hash = combine_hash(element_hash(left), element_hash(right))
      Node { hash, left, right }
    }
  }
}

/// Construct a 'HashTree' from a list of hashes.
/// Note that, while this operation is doable on-chain, it is expensive and
/// preferably done off-chain.
pub fn from_hashes_list(items: List<Hash<Sha2_256, a>>) -> HashTree<a> {
  do_from_hashes_list(items, list.length(items))
}

test from_hashes_list_5() {
  let dog = @"dog"
  let cat = @"cat"
  let mouse = @"mouse"
  let horse = @"horse"

  let serialise_fn = create_string_item_serialise_fn()

  let items =
    [dog, cat, mouse, horse]
  let hashes_items = list.map(items, fn(item) { sha2_256(serialise_fn(item)) })

  let mt = from_hashes_list(hashes_items)

  let left_node_hash =
    sha2_256(
      bytearray.concat(sha2_256(serialise_fn(dog)), sha2_256(serialise_fn(cat))),
    )
  let right_node_hash =
    sha2_256(
      bytearray.concat(
        sha2_256(serialise_fn(mouse)),
        sha2_256(serialise_fn(horse)),
      ),
    )

  let element_hash = sha2_256(bytearray.concat(left_node_hash, right_node_hash))

  Node {
    hash: element_hash,
    left: Node {
      hash: left_node_hash,
      left: Leaf { hash: sha2_256(serialise_fn(dog)) },
      right: Leaf { hash: sha2_256(serialise_fn(cat)) },
    },
    right: Node {
      hash: right_node_hash,
      left: Leaf { hash: sha2_256(serialise_fn(mouse)) },
      right: Leaf { hash: sha2_256(serialise_fn(horse)) },
    },
  } == mt
}

// Check whether a hashed element is part of a 'HashTree' using only its root hash
// and a 'Proof'. The proof is guaranteed to be in log(n) of the size of the
// tree, which is why we are interested in such data-structure in the first
// place.
pub fn member_from_hash(
  item_hash: Hash<Sha2_256, a>,
  element_hash: Hash<Sha2_256, a>,
  proof: Proof<a>,
  serialise_fn: fn(a) -> ByteArray,
) -> Bool {
  when proof is {
    [] -> element_hash == item_hash
    [head, ..tail] ->
      when head is {
        Left { hash: l } ->
          member_from_hash(
            combine_hash(l, item_hash),
            element_hash,
            tail,
            serialise_fn,
          )
        Right { hash: r } ->
          member_from_hash(
            combine_hash(item_hash, r),
            element_hash,
            tail,
            serialise_fn,
          )
      }
  }
}

// Check whether an element is part of a 'HashTree' using only its root hash
// and a 'Proof'.
pub fn member(
  item: a,
  element_hash: Hash<Sha2_256, a>,
  proof: Proof<a>,
  serialise_fn: fn(a) -> ByteArray,
) -> Bool {
  let item_hash = sha2_256(serialise_fn(item))
  member_from_hash(item_hash, element_hash, proof, serialise_fn)
}

test member_1() {
  let dog = @"dog"
  let items =
    [dog]
  let serialise_fn = create_string_item_serialise_fn()
  let mt = from_list(items, serialise_fn)

  let item = dog
  let rh = element_hash(mt)

  expect Some(proof) = get_proof(mt, item, serialise_fn)
  member(item: item, element_hash: rh, proof: proof, serialise_fn: serialise_fn)
}

test member_2() {
  let dog = @"dog"
  let cat = @"cat"
  let mouse = @"mouse"
  let horse = @"horse"

  let items =
    [dog, cat, mouse, horse]
  let serialise_fn = create_string_item_serialise_fn()
  let mt = from_list(items, serialise_fn)

  let item = cat
  let rh = element_hash(mt)

  expect Some(proof) = get_proof(mt, item, serialise_fn)
  member(item: item, element_hash: rh, proof: proof, serialise_fn: serialise_fn)
}

test member_3() {
  let dog = @"dog"
  let cat = @"cat"

  let items =
    [dog, cat]
  let serialise_fn = create_string_item_serialise_fn()
  let mt = from_list(items, serialise_fn)

  let item = cat
  let rh = element_hash(mt)

  expect Some(proof) = get_proof(mt, item, serialise_fn)
  member(item: item, element_hash: rh, proof: proof, serialise_fn: serialise_fn)
}

test member_4() {
  let dog = @"dog"
  let cat = @"cat"
  let mouse = @"mouse"

  let items =
    [dog, cat, mouse]
  let serialise_fn = create_string_item_serialise_fn()
  let mt = from_list(items, serialise_fn)

  let item = mouse
  let rh = element_hash(mt)

  expect Some(proof) = get_proof(mt, item, serialise_fn)
  member(item: item, element_hash: rh, proof: proof, serialise_fn: serialise_fn)
}

test member_5() {
  let dog = @"dog"
  let cat = @"cat"
  let mouse = @"mouse"
  let horse = @"horse"
  let pig = @"pig"
  let bull = @"bull"

  let items =
    [dog, cat, mouse, horse, pig, bull]
  let serialise_fn = create_string_item_serialise_fn()
  let mt = from_list(items, serialise_fn)

  let item = pig
  let rh = element_hash(mt)

  expect Some(proof) = get_proof(mt, item, serialise_fn)
  member(item: item, element_hash: rh, proof: proof, serialise_fn: serialise_fn)
}

test member_6() {
  let dog = @"dog"
  let cat = @"cat"
  let mouse = @"mouse"
  let horse = @"horse"
  let pig = @"pig"
  let bull = @"bull"

  let serialise_fn = create_string_item_serialise_fn()

  let items =
    [dog, cat, mouse, horse, pig, bull]
  let mt = from_list(items, serialise_fn)

  let item = @"parrot"

  is_none(get_proof(mt, item, serialise_fn))
}

pub fn member_from_tree(
  tree: HashTree<a>,
  item: a,
  serialise_fn: fn(a) -> ByteArray,
) -> Bool {
  get_proof(tree, item, serialise_fn) |> option.is_some
}

test member_from_tree_1() {
  let dog = @"dog"
  let cat = @"cat"
  let mouse = @"mouse"
  let horse = @"horse"
  let pig = @"pig"
  let bull = @"bull"

  let serialise_fn = create_string_item_serialise_fn()

  let items =
    [dog, cat, mouse, horse, pig, bull]
  let mt = from_list(items, serialise_fn)

  let item = pig

  member_from_tree(tree: mt, item: item, serialise_fn: serialise_fn)
}

test member_from_tree_2() {
  let dog = @"dog"
  let cat = @"cat"
  let mouse = @"mouse"
  let horse = @"horse"
  let pig = @"pig"
  let bull = @"bull"

  let serialise_fn = create_string_item_serialise_fn()

  let items =
    [dog, cat, mouse, horse, pig, bull]
  let mt = from_list(items, serialise_fn)

  let item = @"parrot"

  member_from_tree(tree: mt, item: item, serialise_fn: serialise_fn) == False
}

test member_from_tree_32() {
  let dog = @"dog"

  let serialise_fn = create_string_item_serialise_fn()

  let items =
    [dog]
  let mt = from_list(items, serialise_fn)

  member_from_tree(tree: mt, item: dog, serialise_fn: serialise_fn)
}

fn get_proof_item_value(proof_item: ProofItem<a>) -> Hash<Sha2_256, a> {
  when proof_item is {
    Left(hash) -> hash
    Right(hash) -> hash
  }
}

// needed only for tests
fn create_string_item_serialise_fn() -> fn(String) -> ByteArray {
  fn(x: String) { from_string(x) }
}
