use aiken/transaction/credential.{Address,
  PublicKeyCredential, ScriptCredential}
  
pub fn keyhash_address(keyhash: ByteArray) {
  Address {
    payment_credential: PublicKeyCredential(keyhash),
    stake_credential: None,
  }
}

pub fn scripthash_address(scripthash: ByteArray) {
  Address {
    payment_credential: ScriptCredential(scripthash),
    stake_credential: None,
  }
}
