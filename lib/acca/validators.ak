use aiken/hash.{Blake2b_224, Hash}
use aiken/list
use aiken/transaction.{Input, Output, OutputReference}
use aiken/transaction/credential.{Script, ScriptCredential}

pub type ValidatorHash =
  Hash<Blake2b_224, Script>

pub fn own_validator_script_address_hash(
  inputs: List<Input>,
  output_reference: OutputReference,
) -> ValidatorHash {
  expect Some(input) =
    list.find(inputs, fn(input) { input.output_reference == output_reference })
  expect ScriptCredential(hash) =
    input.output.address.payment_credential

  hash
}

/// This function helps in scenarios that you need to check
/// whether at least one output consists of payment
/// to validator's own script address.
pub fn any_output_contains_own_validator_address(
  inputs: List<Input>,
  outputs: List<Output>,
  output_reference: OutputReference,
) -> Bool {
  let validator_hash =
    own_validator_script_address_hash(inputs, output_reference)

  let script_creds =
    list.filter(
      outputs,
      fn(o) {
        when o.address.payment_credential is {
          ScriptCredential(_) ->
            True
          _ ->
            False
        }
      },
    )

  list.any(
    script_creds,
    fn(output) {
      expect ScriptCredential(output_script_hash) =
        output.address.payment_credential

      output_script_hash == validator_hash
    },
  )
}
