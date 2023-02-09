use aiken/option.{is_some}

pub fn flat_map(self: Option<a>, with: fn(a) -> Option<b>) -> Option<b> {
  when self is {
    Some(a) -> with(a)
    None -> None
  }
}

test flat_map_1() {
  flat_map(Some(1), fn(x: Int) { Some(x + 1) }) == Some(2)
}

test flat_map_2() {
  flat_map(None, fn(x: Int) { Some(x + 1) }) == None
}

/// Fold is a resolver which allows you to pass two function, one for case when option is empty and one for case where there is a value
fn fold(self: Option<a>, with_empty: fn() -> b, with_present: fn(a) -> b) -> b {
  when self is {
    Some(x) -> with_present(x)
    None -> with_empty()
  }
}

test fold_1() {
  let opt = Some(1)

  fold(opt, fn() { False }, fn(_) { True })
}

test fold_2() {
  let opt = None

  fold(opt, fn() { False }, fn(_) { True }) == False
}

fn filter(self: Option<a>, with: fn(a) -> Bool) -> Option<a> {
  when self is {
    Some(x) ->
      if with(x) {
        Some(x)
      } else {
        None
      }
    None -> None
  }
}

test filter_1() {
  let opt = Some(1)

  filter(opt, fn(x) { x == 1 }) == Some(1)
}

test filter_2() {
  let opt = Some(0)

  filter(opt, fn(x) { x == 1 }) == None
}

fn exists(self: Option<a>, with: fn(a) -> Bool) -> Bool {
  is_some(filter(self, with))
}

test exists_1() {
  exists(Some(1), with: fn(x) { x == 0 }) == False
}

test exists_2() {
  exists(Some(1), with: fn(x) { x == 1 }) == True
}
