use acca/hash.{PubKeyHash}
use aiken/list.{has}
use aiken/transaction.{Transaction}

/// Function that assets that a certain transaction has been signed by a certain public key.
pub fn must_be_signed_by(transaction: Transaction, pkh: PubKeyHash) -> Bool {
  has(transaction.extra_signatories, pkh)
}
