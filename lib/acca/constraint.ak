use acca/hash.{PubKeyHash}
use aiken/list.{has}
use aiken/transaction.{Transaction}

pub fn must_be_signed_by(transaction: Transaction, pkh: PubKeyHash) -> Bool {
  has(transaction.extra_signatories, pkh)
}
