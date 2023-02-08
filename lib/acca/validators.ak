use aiken/hash.{Blake2b_224, Hash}
use aiken/list
use aiken/option
use aiken/transaction.{
  Input, OutputReference, ScriptContext, Spend
}
use aiken/transaction/credential.{
  Script, ScriptCredential
}

pub type ValidatorHash =
  Hash<Blake2b_224, Script>

pub fn own_validator_script_address_hash(
  inputs: List<Input>,
  output_reference: OutputReference,
) -> Option<ValidatorHash> {
  inputs
  |> list.find(fn(input) { input.output_reference == output_reference })
  |> option.map(fn(v) { v.output })
  |> option.map(fn(v) { v.address })
  |> option.map(fn(v) { v.payment_credential })
  |> option.map(
  fn(v) {
    when v is {
      ScriptCredential(hash) -> Some(hash)
      _ -> None
    }
  })
  
  |> option.flatten()
}

/// Return own input, it is pretty much impossible that this fails
pub fn get_own_input(ctx: ScriptContext) -> Input {
  assert Spend(output_reference) = ctx.purpose

  assert Some(input) =
    list.find(
      ctx.transaction.inputs,
      fn(input) { input.output_reference == output_reference },
    )

  input
}
