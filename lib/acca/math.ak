fn max(self: List<Int>) -> Option<Int> {
  when self is {
    [] -> None
    [first] -> Some(first)
    [h, ..t] -> Some(foldl(t, fn(a, b) { math.max(a, b) }, h))
  }
}

test max_1() {
  max([]) == None
}

test max_2() {
  max([9]) == Some(9)
}

test max_3() {
  max([9, 8, 1]) == Some(9)
}

test max_4() {
  max([9, 8, 1, -1, 10]) == Some(10)
}

fn min(self: List<Int>) -> Option<Int> {
  when self is {
    [] -> None
    [first] -> Some(first)
    [h, ..t] -> Some(foldl(t, fn(a, b) { math.min(a, b) }, h))
  }
}

test min_1() {
  min([]) == None
}

test min_2() {
  min([9]) == Some(9)
}

test min_3() {
  min([9, 8, 1]) == Some(1)
}

test min_4() {
  min([9, 8, 1, -1]) == Some(-1)
}

pub fn sum(self: List<Int>) -> Int {
  list.foldl(self, fn(a, b) { a + b }, 0)
}

test sum_1() {
  sum([]) == 0
}

test sum_2() {
  sum([1, 2, 3]) == 6
}

test sum_3() {
  sum([1, 2, 3, 4]) == 10
}

pub fn product(self: List<Int>) -> Int {
  list.foldl(self, fn(a, b) { a * b }, 1)
}

test product_1() {
  product([]) == 1
}

test product_2() {
  product([1, 2, 3]) == 6
}

test product_3() {
  product([1, 2, 3, 4]) == 24
}
