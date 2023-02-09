pub type Either<a, b> {
    Left { value: a }
    Right { value: b } 
}

test either_1() {
    let l: Either<Int, String> = Left { value: 1 }
    let r: Either<Int, String> = Right { value: "" }

    l == Left { value: 1 } && r == Right { value: "" }
}

// pub fn map(self: Either<a>, with: fn(a) -> Either<result>) -> Either<result> {
//     when self is {
//         Left(x) -> Left(x)
//         Right(y) -> with(y)
//     }
// }

// test map_1() {
//     let l: Either<Int, Bool> = Left { value: 1 }

//     map(l, fn(x) { x > 0 } ) == Either<Int> = Left { value: 1 }
// }

