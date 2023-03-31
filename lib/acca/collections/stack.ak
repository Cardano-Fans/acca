use acca/list as alist
use aiken/list

/// Functional stack backed by list.
pub opaque type Stack<a> {
  inner: List<a>,
}

/// Creates new instance of Stack.
/// 
/// ```aiken
/// let s = stack.new()
/// ```
pub fn new() -> Stack<a> {
  Stack { inner: [] }
}

/// Creates Stack instance from a list.
/// 
/// ```aiken
/// let s = stack.from_list([1, 2, 3])
/// ```
pub fn from_list(l: List<a>) -> Stack<a> {
  Stack { inner: l }
}

/// Alias to new()
pub fn empty() -> Stack<a> {
  new()
}

/// Push value on the top of the stack.
/// 
/// ```aiken
/// let s = stack.from_list([1,2,3])
/// stack.push(s, 4) == Stack(inner: [1, 2, 3, 4])
/// ```
pub fn push(self: Stack<a>, value: a) -> Stack<a> {
  Stack(alist.prepend(self.inner, value))
}

/// Pop (remove) value from the top of the stack.
/// 
/// ```aiken
/// let s = stack.from_list([1, 2, 3])
/// stack.pop(s) == (Some(3), rest)
/// ```
pub fn pop(self: Stack<a>) -> (Option<a>, Stack<a>) {
  when self.inner is {
    [] ->
      (None, self)
    [h, ..t] ->
      (Some(h), from_list(t))
  }
}

/// Returns size of the stack.
/// 
/// ```aiken
/// let s = stack.from_list([1, 2, 3])
/// stack.size(s) == 3
/// ```
pub fn size(self: Stack<a>) -> Int {
  list.length(self.inner)
}

/// Function to peek at the element at the top of the stack (without removing element at the top).
/// 
/// ```aiken
/// let s = stack.from_list([1, 2, 3]) |> stack.peek == 3
/// stack.size(s) == 3
/// ```
pub fn peek(self: Stack<a>) -> Option<a> {
  when self.inner is {
    [] ->
      None
    [h, ..] ->
      Some(h)
  }
}

/// Function to check if the stack is empty.
/// 
/// ```aiken
/// let s = stack.from_list([1, 2, 3])
/// stack.size(s) == 3
/// ```
pub fn is_empty(self: Stack<a>) -> Bool {
  when self.inner is {
    [] ->
      True
    _ ->
      False
  }
}

test stack_0() {
  let s =
    new()

  is_empty(s)
}

test stack_1() {
  let s =
    new() |> push(1) |> push(2) |> push(3)

  is_empty(s) == False
}

test stack_2() {
  let s =
    new() |> push(1) |> push(2) |> push(3)

  let (Some(x), stack) =
    pop(s)

  list.and([x == 3, size(stack) == 2])
}

test stack_3() {
  let s =
    new() |> push(1) |> push(2) |> push(3)

  list.and([peek(s) == Some(3), size(s) == 3])
}
