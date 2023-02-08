pub fn flat_map(self: Option<a>, with: fn(a) -> Option<b> ) -> Option<b> {
    when self is {
        Some(a) -> with(a)
        None -> None
    }
}

test flat_map_1() {
    flat_map(Some(1), fn(x: Int) { Some(x + 1) }  ) == Some(2)
}

test flat_map_2() {
    flat_map(None, fn(x: Int) { Some(x + 1) }  ) == None
}
