use aiken/crypto.{Blake2b_224, Hash, VerificationKey}

pub type PubKeyHash =
  Hash<Blake2b_224, VerificationKey>
