pub type Either<a> {
    Left { value: a }
    Right { value: a } 
}

test either_1() {
    let l: Either<Int> = Left { value: 1 }
    let r: Either<Int> = Right { value: 1 }

    l == Left { value: 1 } && r == Right { value: 1 }
}
