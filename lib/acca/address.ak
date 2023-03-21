use aiken/transaction.{Input}
use aiken/transaction/credential.{Address}

/// Function that returns address for a given input
pub fn find_input_address(maybe_input: Option<Input>) -> Address {
  when maybe_input is {
    Some(input) -> input.output.address
    None -> error @"Unable to find address"
  }
}
